// lib/services/signin_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:air_track_app/services/auth_storage.dart';

class SigninApiService {
  final String baseUrl;

  SigninApiService({required this.baseUrl});

  /// Log in with email & password.
  /// - Saves token to AuthStorage.
  /// - If the response contains a `user` object, saves it to AuthStorage as well.
  /// Returns the token string on success.
  Future<String> loginWithEmail(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // common token fields
        final token = data['token'] ?? data['access_token'];

        if (token == null || token.toString().isEmpty) {
          throw ApiException('No token returned from the server.');
        }

        // Save token securely
        await AuthStorage.saveToken(token.toString());

        // If server returned a user object, save it securely
        try {
          final serverUser = data['user'] ?? data['data'] ?? null;
          if (serverUser != null) {
            // Ensure it's a Map<String, dynamic>
            if (serverUser is Map<String, dynamic>) {
              await AuthStorage.saveUser(serverUser);
            } else {
              // sometimes the decoded type is Map but dynamic; attempt conversion
              final Map<String, dynamic> parsed = Map<String, dynamic>.from(
                serverUser,
              );
              await AuthStorage.saveUser(parsed);
            }
          }
        } catch (e) {
          // Non-fatal: continue even if saving user fails
          print('⚠️ Could not save user from login response: $e');
        }

        return token.toString();
      } else {
        final statusCode = response.statusCode;
        String apiMessage = '';

        // try parse response body for message
        try {
          final parsed = jsonDecode(response.body);
          apiMessage = parsed['message']?.toString() ?? '';
        } catch (_) {
          apiMessage = '';
        }

        final lowerMessage = apiMessage.toLowerCase();

        String errorMessage;
        if (lowerMessage.contains('user not found') ||
            lowerMessage.contains('not found') ||
            statusCode == 404) {
          errorMessage = 'No account found with this email';
        } else if (lowerMessage.contains('credentials') ||
            lowerMessage.contains('password') ||
            lowerMessage.contains('incorrect') ||
            lowerMessage.contains('unauthorized') ||
            lowerMessage.contains('invalid')) {
          errorMessage = 'Incorrect email or password';
        } else if (statusCode == 422) {
          try {
            final parsed = jsonDecode(response.body);
            if (parsed['errors'] != null && parsed['errors'] is Map) {
              final errors = parsed['errors'] as Map<String, dynamic>;
              final firstError = errors.values.first;
              errorMessage = firstError is List
                  ? firstError.first.toString()
                  : firstError.toString();
            } else {
              errorMessage = apiMessage.isNotEmpty
                  ? apiMessage
                  : 'Invalid input';
            }
          } catch (_) {
            errorMessage = 'Invalid input';
          }
        } else {
          errorMessage = apiMessage.isNotEmpty
              ? apiMessage
              : 'Authentication failed';
        }

        throw ApiException(errorMessage, statusCode: statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      print('🔴 loginWithEmail error: $e');
      throw ApiException('Network error: Unable to connect to server');
    }
  }

  /// Fetch profile from server using Bearer token (use if login returns only token).
  /// Saves profile to AuthStorage and returns the profile map.
  Future<Map<String, dynamic>> fetchProfile(String token) async {
    final url = Uri.parse(
      '$baseUrl/profile',
    ); // change to your actual profile endpoint if different (e.g., /me)
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Adjust according to your API response structure: some APIs return { "user": {...} }
        final user = data['user'] ?? data;
        if (user is Map<String, dynamic>) {
          await AuthStorage.saveUser(user);
          return user;
        } else {
          // attempt conversion if needed
          final parsed = Map<String, dynamic>.from(user);
          await AuthStorage.saveUser(parsed);
          return parsed;
        }
      } else {
        final statusCode = response.statusCode;
        String apiMessage = '';
        try {
          final parsed = jsonDecode(response.body);
          apiMessage = parsed['message']?.toString() ?? '';
        } catch (_) {}
        throw ApiException(
          apiMessage.isNotEmpty ? apiMessage : 'Failed to fetch profile',
          statusCode: statusCode,
        );
      }
    } catch (e) {
      print('🔴 fetchProfile error: $e');
      rethrow;
    }
  }
}

/// Simple ApiException used for easier error handling in views
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
