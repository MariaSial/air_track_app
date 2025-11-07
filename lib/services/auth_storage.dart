// lib/services/auth_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _tokenKey = 'auth_token';
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
}
