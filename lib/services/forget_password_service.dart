import 'dart:convert';
import 'package:http/http.dart' as http;

class ForgetPasswordApiService {
  final String baseUrl;

  ForgetPasswordApiService({required this.baseUrl});

  /// Sends password reset request to POST /forgot-password
  /// Returns the API message on success.
  Future<String> sendForgotPassword(String email) async {
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

      final status = response.statusCode;
      String bodyMessage = 'Password reset request sent.';

      if (response.body.isNotEmpty) {
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] != null) {
            bodyMessage = data['message'].toString();
          } else if (data is String) {
            bodyMessage = data;
          }
        } catch (_) {
          // ignore parse errors, we'll fall back to raw body
          if (response.body.isNotEmpty) bodyMessage = response.body;
        }
      }

      if (status == 200 || status == 201 || status == 204) {
        // Success - return message (if any)
        return bodyMessage;
      } else if (status == 401) {
        throw ForgotPasswordException(
          'This feature is currently unavailable. Please contact support.',
          statusCode: 401,
        );
      } else if (status == 404) {
        throw ForgotPasswordException(
          'No account found with this email address',
          statusCode: 404,
        );
      } else if (status == 422) {
        // Validation error: try to extract meaningful error message
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
        // other error codes
        String errorMessage = 'Failed to send reset email';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message']?.toString() ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) errorMessage = response.body;
        }
        throw ForgotPasswordException(errorMessage, statusCode: status);
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

class ForgotPasswordException implements Exception {
  final String message;
  final int? statusCode;

  ForgotPasswordException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
