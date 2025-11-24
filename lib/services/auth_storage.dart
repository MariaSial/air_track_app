// lib/services/auth_storage.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_profile';
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Save token (e.g. after successful sign in)
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Read token. This is the method your ReportsView expects.
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete token (sign out)
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Save user profile map securely (serializes to JSON)
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final jsonStr = jsonEncode(user);
    await _storage.write(key: _userKey, value: jsonStr);
  }

  /// Get saved user profile map or null if none
  static Future<Map<String, dynamic>?> getUser() async {
    final jsonStr = await _storage.read(key: _userKey);
    if (jsonStr == null) return null;
    try {
      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
      return parsed;
    } catch (_) {
      return null;
    }
  }

  /// Clear saved profile (logout)
  static Future<void> clearUser() async {
    await _storage.delete(key: _userKey);
  }
}
