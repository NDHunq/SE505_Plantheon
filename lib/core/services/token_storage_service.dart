import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  final SharedPreferences _prefs;

  TokenStorageService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  /// Get stored authentication token
  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    await _prefs.remove(_tokenKey);
  }

  /// Save user data
  Future<void> saveUser(UserModel user) async {
    final userJson = json.encode(user.toJson());
    await _prefs.setString(_userKey, userJson);
  }

  /// Get stored user data
  Future<UserModel?> getUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson == null) return null;

    try {
      final userMap = json.decode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  /// Delete user data
  Future<void> deleteUser() async {
    await _prefs.remove(_userKey);
  }

  /// Clear all authentication data
  Future<void> clear() async {
    await deleteToken();
    await deleteUser();
  }
}
