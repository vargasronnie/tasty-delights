import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../models/order.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        'tasty_delights.db',
        version: 1,
        onCreate: _onCreate,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'tasty_delights.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Cart items table
    await db.execute('''
      CREATE TABLE cart_items (
        id TEXT PRIMARY KEY,
        food_id TEXT NOT NULL,
        food_name TEXT NOT NULL,
        food_description TEXT NOT NULL,
        food_price REAL NOT NULL,
        food_image TEXT NOT NULL,
        food_category TEXT NOT NULL,
        food_rating REAL NOT NULL,
        food_review_count INTEGER NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        total_amount REAL NOT NULL,
        order_date TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        delivery_address TEXT NOT NULL
      )
    ''');

    // Order items table (relation to orders)
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        food_id TEXT NOT NULL,
        food_name TEXT NOT NULL,
        food_description TEXT NOT NULL,
        food_price REAL NOT NULL,
        food_image TEXT NOT NULL,
        food_category TEXT NOT NULL,
        food_rating REAL NOT NULL,
        food_review_count INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites (
        food_id TEXT PRIMARY KEY
      )
    ''');

    // Foods cache table
    await db.execute('''
      CREATE TABLE foods_cache (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT NOT NULL,
        category TEXT NOT NULL,
        rating REAL NOT NULL,
        review_count INTEGER NOT NULL
      )
    ''');
  }

  // ─── CART ────────────────────────────────────────────────
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final rows = await db.query('cart_items');
    return rows.map((row) {
      final food = FoodItem(
        id: row['food_id'] as String,
        name: row['food_name'] as String,
        description: row['food_description'] as String,
        price: row['food_price'] as double,
        imageUrl: row['food_image'] as String,
        category: row['food_category'] as String,
        rating: row['food_rating'] as double,
        reviewCount: row['food_review_count'] as int,
      );
      return CartItem(food: food, quantity: row['quantity'] as int);
    }).toList();
  }

  Future<void> upsertCartItem(CartItem item) async {
    final db = await database;
    await db.insert(
      'cart_items',
      {
        'id': item.foodItem.id,
        'food_id': item.foodItem.id,
        'food_name': item.foodItem.name,
        'food_description': item.foodItem.description,
        'food_price': item.foodItem.price,
        'food_image': item.foodItem.imageUrl,
        'food_category': item.foodItem.category,
        'food_rating': item.foodItem.rating,
        'food_review_count': item.foodItem.reviewCount,
        'quantity': item.quantity,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAllCartItems(List<CartItem> items) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('cart_items');
    for (final item in items) {
      batch.insert('cart_items', {
        'id': item.foodItem.id,
        'food_id': item.foodItem.id,
        'food_name': item.foodItem.name,
        'food_description': item.foodItem.description,
        'food_price': item.foodItem.price,
        'food_image': item.foodItem.imageUrl,
        'food_category': item.foodItem.category,
        'food_rating': item.foodItem.rating,
        'food_review_count': item.foodItem.reviewCount,
        'quantity': item.quantity,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteCartItem(String foodId) async {
    final db = await database;
    await db.delete('cart_items', where: 'food_id = ?', whereArgs: [foodId]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // ─── ORDERS ─────────────────────────────────────────────
  Future<List<Order>> getOrders() async {
    final db = await database;
    final orderRows = await db.query('orders', orderBy: 'order_date DESC');
    final List<Order> orders = [];

    for (final row in orderRows) {
      final orderId = row['id'] as String;
      final itemRows = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final cartItems = itemRows.map((ir) {
        final food = FoodItem(
          id: ir['food_id'] as String,
          name: ir['food_name'] as String,
          description: ir['food_description'] as String,
          price: ir['food_price'] as double,
          imageUrl: ir['food_image'] as String,
          category: ir['food_category'] as String,
          rating: ir['food_rating'] as double,
          reviewCount: ir['food_review_count'] as int,
        );
        return CartItem(food: food, quantity: ir['quantity'] as int);
      }).toList();

      orders.add(Order(
        id: orderId,
        items: cartItems,
        totalAmount: row['total_amount'] as double,
        orderDate: DateTime.parse(row['order_date'] as String),
        status: OrderStatus.values[row['status'] as int],
        deliveryAddress: row['delivery_address'] as String,
      ));
    }
    return orders;
  }

  Future<void> insertOrder(Order order) async {
    final db = await database;
    final batch = db.batch();

    batch.insert('orders', {
      'id': order.id,
      'total_amount': order.totalAmount,
      'order_date': order.orderDate.toIso8601String(),
      'status': order.status.index,
      'delivery_address': order.deliveryAddress,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    for (final item in order.items) {
      batch.insert('order_items', {
        'order_id': order.id,
        'food_id': item.foodItem.id,
        'food_name': item.foodItem.name,
        'food_description': item.foodItem.description,
        'food_price': item.foodItem.price,
        'food_image': item.foodItem.imageUrl,
        'food_category': item.foodItem.category,
        'food_rating': item.foodItem.rating,
        'food_review_count': item.foodItem.reviewCount,
        'quantity': item.quantity,
      });
    }

    await batch.commit(noResult: true);
  }

  // ─── FAVORITES ──────────────────────────────────────────
  Future<List<String>> getFavoriteIds() async {
    final db = await database;
    final rows = await db.query('favorites');
    return rows.map((r) => r['food_id'] as String).toList();
  }

  Future<void> saveFavorites(List<String> ids) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('favorites');
    for (final id in ids) {
      batch.insert('favorites', {'food_id': id},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ─── FOODS CACHE ─────────────────────────────────────────
  Future<List<FoodItem>> getCachedFoods() async {
    final db = await database;
    final rows = await db.query('foods_cache');
    return rows.map((row) => FoodItem(
      id: row['id'] as String,
      name: row['name'] as String,
      description: row['description'] as String,
      price: row['price'] as double,
      imageUrl: row['image_url'] as String,
      category: row['category'] as String,
      rating: row['rating'] as double,
      reviewCount: row['review_count'] as int,
    )).toList();
  }

  Future<void> cacheFoods(List<FoodItem> foods) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('foods_cache');
    for (final food in foods) {
      batch.insert('foods_cache', {
        'id': food.id,
        'name': food.name,
        'description': food.description,
        'price': food.price,
        'image_url': food.imageUrl,
        'category': food.category,
        'rating': food.rating,
        'review_count': food.reviewCount,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  // ─── CLOSE ──────────────────────────────────────────────
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
