// lib/services/contact_apiservice.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ContactApiservice {
  final String baseUrl;

  ContactApiservice({required this.baseUrl});

  /// Sends contact us message without requiring authentication
  Future<String> sendContactUs({
    required String name,
    required String email,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl/contact-us');

    try {
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'name': name,
        'email': email,
        'message': message,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['message']?.toString() ?? 'Message sent successfully';
      } else if (response.statusCode == 422) {
        // Validation Error
        String errorMessage = 'Invalid input';
        try {
          final data = jsonDecode(response.body);
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first;
            errorMessage = firstError is List
                ? firstError.first.toString()
                : firstError.toString();
          } else if (data['message'] != null) {
            errorMessage = data['message'].toString();
          }
        } catch (_) {}
        throw ContactException(errorMessage, statusCode: 422);
      } else {
        // Other Errors
        String errorMessage = 'Failed to send message';
        try {
          final data = jsonDecode(response.body);
          errorMessage = data['message']?.toString() ?? errorMessage;
        } catch (_) {
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw ContactException(errorMessage, statusCode: response.statusCode);
      }
    } on ContactException {
      rethrow;
    } catch (e) {
      throw ContactException('Network error: Unable to connect to server');
    }
  }
}

class ContactException implements Exception {
  final String message;
  final int? statusCode;

  ContactException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
