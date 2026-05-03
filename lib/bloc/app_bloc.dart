import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/order.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/firebase_service.dart';
import '../services/mock_data_service.dart';

class AppBloc extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();
  final DatabaseService _db = DatabaseService();

  UserModel? _currentUser;
  List<FoodItem> _allFoods = [];
  List<CartItem> _cartItems = [];
  List<Order> _orders = [];
  List<String> _favoriteIds = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  StreamSubscription<List<Order>>? _ordersSubscription;
  String? _lastLoadedUid;

  UserModel? get currentUser => _currentUser;
  List<FoodItem> get allFoods => _allFoods;
  List<CartItem> get cartItems => _cartItems;
  List<Order> get orders => _orders;
  List<String> get favoriteIds => _favoriteIds;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  int get cartCount => _cartItems.fold(0, (s, i) => s + i.quantity);
  double get cartTotal => _cartItems.fold(0.0, (s, i) => s + i.totalPrice);

  List<FoodItem> get filteredFoods {
    var foods = _allFoods;
    if (_selectedCategory != 'All') {
      foods = foods.where((f) => f.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      foods = foods
          .where((f) =>
              f.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return foods;
  }

  List<FoodItem> get specialOffers {
    if (_allFoods.isEmpty) return [];
    final offers = _allFoods
        .where((f) =>
            f.id == '1' || f.id == '3' || f.id == '5' || f.id == '8')
        .toList();
    return offers.isNotEmpty ? offers : _allFoods.take(4).toList();
  }

  // ─── INIT ────────────────────────────────────────────────
  Future<void> init() async {}

  Future<void> loadAfterAuth(String uid) async {
    if (_lastLoadedUid == uid) return;
    _lastLoadedUid = uid;

    // Load mock foods immediately
    if (_allFoods.isEmpty) {
      _allFoods = MockDataService.getFoodItems();
      notifyListeners();
    }

    // Load from SQLite
    try {
      _cartItems = await _db.getCartItems();
      _favoriteIds = await _db.getFavoriteIds();
      _orders = await _db.getOrders(); // ← load orders from SQLite
      final cached = await _db.getCachedFoods();
      if (cached.isNotEmpty) _allFoods = cached;
      notifyListeners();
    } catch (e) {
      debugPrint('SQLite load error: $e');
    }

    // Load user profile
    try {
      _currentUser = await _firebase
          .getUserProfile(uid)
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      notifyListeners();
    } catch (e) {
      debugPrint('User profile error: $e');
    }

    // Background Firebase sync
    _doBackgroundSync(uid);
  }

  void _doBackgroundSync(String uid) {
    Future(() async {
      try {
        // Sync foods
        final firebaseFoods = await _firebase
            .getFoodItems()
            .timeout(const Duration(seconds: 10));
        if (firebaseFoods.isEmpty) {
          final mock = MockDataService.getFoodItems();
          await _firebase.seedFoodItems(mock);
          _allFoods = mock;
          await _db.cacheFoods(mock);
        } else {
          _allFoods = firebaseFoods;
          await _db.cacheFoods(firebaseFoods);
        }

        // Sync favorites
        final fbFavs = await _firebase
            .getFavorites(uid)
            .timeout(const Duration(seconds: 5));
        _favoriteIds = fbFavs;
        await _db.saveFavorites(fbFavs);

        // Stream orders from Firebase and merge with SQLite orders
        _ordersSubscription?.cancel();
        _ordersSubscription =
            _firebase.ordersStream(uid).listen((List<Order> fbOrders) async {
          // Save Firebase orders to SQLite
          for (final o in fbOrders) {
            await _db.insertOrder(o);
          }
          // Reload all orders from SQLite to get complete list
          _orders = await _db.getOrders();
          notifyListeners();
        });

        notifyListeners();
      } catch (e) {
        debugPrint('Background sync error: $e');
      }
    });
  }

  // ─── AUTH ────────────────────────────────────────────────
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebase
          .signIn(email, password)
          .timeout(const Duration(seconds: 15));
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      final msg = e.toString();
      if (msg.contains('TimeoutException')) {
        return 'Connection timed out. Check your internet.';
      }
      return msg;
    }
  }

  Future<String?> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firebase
          .register(name, email, password)
          .timeout(const Duration(seconds: 15));
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      final msg = e.toString();
      if (msg.contains('TimeoutException')) {
        return 'Connection timed out. Check your internet.';
      }
      return msg;
    }
  }

  Future<void> logout() async {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _lastLoadedUid = null;
    try {
      await _firebase.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    await _db.clearCart();
    await _db.saveFavorites([]);
    _currentUser = null;
    _cartItems = [];
    _orders = [];
    _favoriteIds = [];
    _allFoods = [];
    notifyListeners();
  }

  Future<void> sendPasswordReset(String email) async {
    await _firebase.sendPasswordReset(email);
  }

  // ─── FOOD ────────────────────────────────────────────────
  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  // ─── CART ────────────────────────────────────────────────
  void addToCart(FoodItem food) {
    final idx = _cartItems.indexWhere((i) => i.foodItem.id == food.id);
    if (idx >= 0) {
      _cartItems[idx].quantity++;
    } else {
      _cartItems.add(CartItem(food: food));
    }
    _db.saveAllCartItems(_cartItems);
    notifyListeners();
  }

  void removeFromCart(String foodId) {
    _cartItems.removeWhere((i) => i.foodItem.id == foodId);
    _db.deleteCartItem(foodId);
    notifyListeners();
  }

  void updateCartQuantity(String foodId, int qty) {
    final idx = _cartItems.indexWhere((i) => i.foodItem.id == foodId);
    if (idx >= 0) {
      if (qty <= 0) {
        _cartItems.removeAt(idx);
        _db.deleteCartItem(foodId);
      } else {
        _cartItems[idx].quantity = qty;
        _db.saveAllCartItems(_cartItems);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _cartItems = [];
    _db.clearCart();
    notifyListeners();
  }

  // ─── ORDERS ─────────────────────────────────────────────
  Future<Order?> placeOrder(String address) async {
    if (_cartItems.isEmpty) return null;

    // Ensure user is loaded
    if (_currentUser == null) {
      try {
        final fbUser = _firebase.currentFirebaseUser;
        if (fbUser == null) return null;
        _currentUser = await _firebase
            .getUserProfile(fbUser.uid)
            .timeout(const Duration(seconds: 5), onTimeout: () => null);
        _currentUser ??= UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'User',
          email: fbUser.email ?? '',
        );
      } catch (e) {
        final fbUser = _firebase.currentFirebaseUser;
        if (fbUser == null) return null;
        _currentUser = UserModel(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'User',
          email: fbUser.email ?? '',
        );
      }
    }

    try {
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: List<CartItem>.from(_cartItems),
        totalAmount: cartTotal,
        orderDate: DateTime.now(),
        status: OrderStatus.confirmed,
        deliveryAddress: address,
      );

      // 1. Save to SQLite immediately
      await _db.insertOrder(order);

      // 2. Reload orders from SQLite so UI updates
      _orders = await _db.getOrders();

      // 3. Clear cart
      _cartItems = [];
      await _db.clearCart();

      // 4. Notify UI
      notifyListeners();

      // 5. Sync to Firebase in background
      Future(() async {
        try {
          await _firebase.saveOrder(_currentUser!.id, order);
        } catch (e) {
          debugPrint('Firebase order sync: $e');
        }
      });

      return order;
    } catch (e) {
      debugPrint('Place order error: $e');
      return null;
    }
  }

  // ─── FAVORITES ──────────────────────────────────────────
  Future<void> toggleFavorite(String foodId) async {
    if (_currentUser == null) return;
    if (_favoriteIds.contains(foodId)) {
      _favoriteIds.remove(foodId);
    } else {
      _favoriteIds.add(foodId);
    }
    await _db.saveFavorites(_favoriteIds);
    try {
      await _firebase.updateFavorites(_currentUser!.id, _favoriteIds);
    } catch (e) {
      debugPrint('Favorites sync: $e');
    }
    notifyListeners();
  }

  bool isFavorite(String foodId) => _favoriteIds.contains(foodId);

  // ─── USER ────────────────────────────────────────────────
  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
    try {
      await _firebase.updateUserProfile(user);
    } catch (e) {
      debugPrint('User update: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
