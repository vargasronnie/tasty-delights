import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class LocalDbService {
  static const String _cartKey = 'cart_items';
  static const String _ordersKey = 'orders';
  static const String _favoritesKey = 'favorites';

  // CART
  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);
    if (cartJson == null) return [];
    final List decoded = jsonDecode(cartJson);
    return decoded.map((e) => CartItem.fromMap(e)).toList();
  }

  Future<void> saveCartItems(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, jsonEncode(items.map((e) => e.toMap()).toList()));
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  // ORDERS
  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersJson = prefs.getString(_ordersKey);
    if (ordersJson == null) return [];
    final List decoded = jsonDecode(ordersJson);
    return decoded.map((e) => Order.fromMap(e)).toList();
  }

  Future<void> saveOrder(Order order) async {
    final orders = await getOrders();
    orders.insert(0, order);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ordersKey, jsonEncode(orders.map((e) => e.toMap()).toList()));
  }

  // FAVORITES
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> toggleFavorite(String foodId) async {
    final favorites = await getFavoriteIds();
    if (favorites.contains(foodId)) {
      favorites.remove(foodId);
    } else {
      favorites.add(foodId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }
}
