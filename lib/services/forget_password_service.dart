import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgetPasswordApiService {
  final String baseUrl;

  ForgetPasswordApiService({required this.baseUrl});

  /// Send password reset email via API: POST /forgot-password
  /// Note: This endpoint should NOT require authentication, but if your API requires it,
  /// you'll need to contact your backend team to fix this.
  Future<void> sendForgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    try {
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Success - password reset email sent
        return;
      } else if (response.statusCode == 401) {
        // Unauthenticated - This is an API design issue
        throw ForgotPasswordException(
          'This feature is currently unavailable. Please contact support.',
          statusCode: 401,
        );
      } else if (response.statusCode == 404) {
        // Email not found
        throw ForgotPasswordException(
          'No account found with this email address',
          statusCode: 404,
        );
      } else if (response.statusCode == 422) {
        // Validation error
        String message = 'Invalid email address';
        try {
          final data = jsonDecode(response.body);
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            message = firstError is List
                ? firstError.first.toString()
                : firstError.toString();
          } else if (data['message'] != null) {
            message = data['message'].toString();
          }
        } catch (_) {}
        throw ForgotPasswordException(message, statusCode: 422);
      } else {
        // Other errors
        String errorMessage = 'Failed to send reset email';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message']?.toString() ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw ForgotPasswordException(
          errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on ForgotPasswordException {
      rethrow;
    } catch (e) {
      throw ForgotPasswordException(
        'Network error: Unable to connect to server',
      );
    }
  }
}

/// Custom exception for forgot password errors
class ForgotPasswordException implements Exception {
  final String message;
  final int? statusCode;

  ForgotPasswordException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
