// lib/services/profile_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:air_track_app/services/auth_storage.dart';

class ProfileApiService {
  final String baseUrl;

  ProfileApiService({required this.baseUrl});

  /// Update profile on server. Expects token for Authorization.
  /// Sends: name, email, city, cnic, phone
  /// Returns the server 'user' map on success.
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String email,
    required String city,
    required String cnic,
    required String phone,
  }) async {
    final url = Uri.parse(
      '$baseUrl/update-profile',
    ); // change endpoint if needed
    final body = {
      'name': name,
      'email': email,
      'city': city,
      'cnic': cnic,
      'phone': phone,
    };

    final resp = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      final decoded = jsonDecode(resp.body);
      // Support structures like { "message": "...", "user": {...} } or { "data": {...} } or plain user map
      final user = decoded['user'] ?? decoded['data'] ?? decoded;
      if (user is Map<String, dynamic>) {
        return user;
      } else {
        // attempt conversion if it's dynamic Map
        return Map<String, dynamic>.from(user);
      }
    } else {
      // Try to extract error message from body
      String apiMessage = 'Failed to update profile (${resp.statusCode})';
      try {
        final parsed = jsonDecode(resp.body);
        if (parsed is Map && parsed['message'] != null) {
          apiMessage = parsed['message'].toString();
        } else if (parsed is Map && parsed['errors'] != null) {
          final errors = parsed['errors'];
          if (errors is Map) {
            apiMessage = errors.entries
                .map((e) => '${e.key}: ${(e.value as List).join(", ")}')
                .join('\n');
          } else {
            apiMessage = parsed.toString();
          }
        } else {
          apiMessage = resp.body;
        }
      } catch (_) {
        apiMessage = resp.body;
      }
      throw Exception(apiMessage);
    }
  }

  /// Optional: fetch profile using token (if you need it elsewhere)
  Future<Map<String, dynamic>> fetchProfile({required String token}) async {
    final url = Uri.parse('$baseUrl/update-profile'); // adjust if different
    final resp = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (resp.statusCode == 200) {
      final decoded = jsonDecode(resp.body);
      final user = decoded['user'] ?? decoded['data'] ?? decoded;
      if (user is Map<String, dynamic>) {
        await AuthStorage.saveUser(user);
        return user;
      } else {
        final parsed = Map<String, dynamic>.from(user);
        await AuthStorage.saveUser(parsed);
        return parsed;
      }
    } else {
      throw Exception('Failed to fetch profile (${resp.statusCode})');
    }
  }
}
