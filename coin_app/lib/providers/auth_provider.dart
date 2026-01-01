import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null && _token != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  Future<void> loadStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    
    if (_token != null) {
      ApiService.setToken(_token);
      try {
        await fetchProfile();
      } catch (e) {
        await logout();
      }
    }
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/register', {
        'email': email,
        'password': password,
        'name': name,
      });

      _user = User.fromJson(response['user']);
      _token = response['token'];
      ApiService.setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      _user = User.fromJson(response['user']);
      _token = response['token'];
      ApiService.setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', _token!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    final response = await ApiService.get('/user/profile');
    _user = User.fromJson(response);
    notifyListeners();
  }

  void updateCoins(int newCoins) {
    if (_user != null) {
      _user = _user!.copyWith(coins: newCoins);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    ApiService.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    
    notifyListeners();
  }
}
