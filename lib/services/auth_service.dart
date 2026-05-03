import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Simulated registered users
  static final List<Map<String, String>> _registeredUsers = [
    {
      'email': 'vargasronnie1234@gmail.com',
      'password': '1234567',
      'name': 'Ronnie Vargas'
    },
    {'email': 'demo@demo.com', 'password': 'demo123', 'name': 'Demo User'},
  ];

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network

    final user = _registeredUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) return false;

    final userModel = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: user['name']!,
      email: user['email']!,
      address: '123 Flavor Street, Food City',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userModel.toMap()));
    await prefs.setBool(_isLoggedInKey, true);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return UserModel.fromMap(jsonDecode(userJson));
  }

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toMap()));
  }
}
