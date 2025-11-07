// lib/services/signin_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:air_track_app/services/auth_storage.dart'; // <-- new import

class SigninApiService {
  final String baseUrl;

  SigninApiService({required this.baseUrl});

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
        final token = data['token'] ?? data['access_token'];

        if (token == null || token.toString().isEmpty) {
          throw ApiException('No token returned from the server.');
        }

        // ✅ Save token securely for later use (Contact API etc.)
        await AuthStorage.saveToken(token.toString());

        return token.toString();
      } else {
        int statusCode = response.statusCode;
        String errorMessage;

        // Try to parse message from response
        String apiMessage = '';
        try {
          final data = jsonDecode(response.body);
          apiMessage = data['message']?.toString() ?? '';
        } catch (_) {}

        final lowerMessage = apiMessage.toLowerCase();

        if (lowerMessage.contains('user not found') ||
            lowerMessage.contains('not found') ||
            lowerMessage.contains('no account') ||
            lowerMessage.contains('email not') ||
            lowerMessage.contains('does not exist') ||
            lowerMessage.contains('doesn\'t exist') ||
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
            final data = jsonDecode(response.body);
            if (data['errors'] != null && data['errors'] is Map) {
              final errors = data['errors'] as Map<String, dynamic>;
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
      throw ApiException('Network error: Unable to connect to server');
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
