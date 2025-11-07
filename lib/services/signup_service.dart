// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupApiService {
  SignupApiService({required this.baseUrl});
  final String baseUrl;

  /// Register: POST /register
  /// Expects fields: name, email, password, password_confirmation, city, phone, cnic
  /// Returns the parsed response map on success (201 or 200), otherwise throws.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String city,
    required String phone,
    required String cnic,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    final body = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'city': city,
      'phone': phone,
      'cnic': cnic,
    };

    final resp = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 201 || resp.statusCode == 200) {
      try {
        final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
        return parsed;
      } catch (_) {
        return {'message': 'Registered', 'raw': resp.body};
      }
    }

    // Try to parse error body
    String errMsg = 'Registration failed (${resp.statusCode})';
    try {
      final parsed = jsonDecode(resp.body);
      if (parsed is Map && parsed['message'] != null) {
        errMsg = parsed['message'].toString();
      } else if (parsed is Map && parsed['errors'] != null) {
        // Laravel-like validation errors
        final errors = parsed['errors'];
        if (errors is Map) {
          final flat = errors.entries
              .map((e) => '${e.key}: ${(e.value as List).join(", ")}')
              .join('\n');
          errMsg = flat;
        } else {
          errMsg = parsed.toString();
        }
      } else {
        errMsg = resp.body;
      }
    } catch (_) {
      errMsg = resp.body;
    }

    throw Exception(errMsg);
  }
}
