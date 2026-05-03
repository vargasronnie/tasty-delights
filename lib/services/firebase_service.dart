import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../models/order.dart' as app_order;
import '../models/cart_item.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  Future<UserCredential?> register(
      String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await cred.user?.updateDisplayName(name);
      await _db.collection('users').doc(cred.user!.uid).set({
        'id': cred.user!.uid,
        'name': name,
        'email': email,
        'phone': '',
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  String _authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return UserModel(
      id: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
    );
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.id).update({
      'name': user.name,
      'phone': user.phone,
      'address': user.address,
    });
    await _auth.currentUser?.updateDisplayName(user.name);
  }

  Future<void> seedFoodItems(List<FoodItem> items) async {
    final batch = _db.batch();
    for (final item in items) {
      final ref = _db.collection('foods').doc(item.id);
      batch.set(ref, item.toMap(), SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<List<FoodItem>> getFoodItems() async {
    final snap = await _db.collection('foods').get();
    return snap.docs.map((d) => FoodItem.fromMap(d.data())).toList();
  }

  Future<List<String>> getFavorites(String uid) async {
    final doc = await _db.collection('favorites').doc(uid).get();
    if (!doc.exists) return [];
    return List<String>.from(doc.data()?['ids'] ?? []);
  }

  Future<void> updateFavorites(String uid, List<String> ids) async {
    await _db
        .collection('favorites')
        .doc(uid)
        .set({'ids': ids}, SetOptions(merge: true));
  }

  Future<void> saveOrder(String uid, app_order.Order order) async {
    await _db.collection('orders').doc(order.id).set({
      'id': order.id,
      'userId': uid,
      'items': order.items
          .map((i) => {
                'foodId': i.foodItem.id,
                'foodName': i.foodItem.name,
                'foodImage': i.foodItem.imageUrl,
                'price': i.foodItem.price,
                'quantity': i.quantity,
              })
          .toList(),
      'totalAmount': order.totalAmount,
      'orderDate': FieldValue.serverTimestamp(),
      'status': order.status.index,
      'deliveryAddress': order.deliveryAddress,
    });
  }

  Stream<List<app_order.Order>> ordersStream(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = d.data();
              final rawItems =
                  List<Map<String, dynamic>>.from(data['items'] ?? []);
              final cartItems = rawItems.map((item) {
                final food = FoodItem(
                  id: item['foodId'] ?? '',
                  name: item['foodName'] ?? '',
                  description: '',
                  price: (item['price'] ?? 0).toDouble(),
                  imageUrl: item['foodImage'] ?? '',
                  category: '',
                );
                return CartItem(food: food, quantity: item['quantity'] ?? 1);
              }).toList();
              return app_order.Order(
                id: data['id'] ?? d.id,
                items: cartItems,
                totalAmount: (data['totalAmount'] ?? 0).toDouble(),
                orderDate: (data['orderDate'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                status: app_order.OrderStatus.values[data['status'] ?? 0],
                deliveryAddress: data['deliveryAddress'] ?? '',
              );
            }).toList());
  }
}
