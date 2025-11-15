import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class NotificationService {
  static const String baseUrl =
      "https://testproject.famzhost.com/api/v1"; // Replace with your actual base URL

  /// Get auth token from secure storage
  Future<String> _getAuthToken() async {
    final token = await AuthStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Auth token not found. Please login.');
    }
    return token;
  }

  /// Get all notifications, optionally expand relations (e.g. 'report')
  /// Get all notifications, optionally expand relations (e.g. 'report')
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 10,
    String? expand,
  }) async {
    try {
      final token = await _getAuthToken();
      final params = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (expand != null && expand.isNotEmpty) params['expand'] = expand;

      final uri = Uri.parse(
        '$baseUrl/notifications',
      ).replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 204 || response.statusCode == 404) {
        // No notifications found; return an empty data payload
        return {'success': true, 'data': <dynamic>[]};
      } else {
        // Log server response to help debugging (500 will show server body)
        debugPrint(
          'getNotifications failed: ${response.statusCode} ${response.body}',
        );
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Get a single notification with optional expand (e.g. report)
  Future<Map<String, dynamic>> getNotificationDetail(
    String id, {
    String? expand,
  }) async {
    try {
      final token = await _getAuthToken();
      final params = <String, String>{};
      if (expand != null && expand.isNotEmpty) params['expand'] = expand;

      final uri = Uri.parse(
        '$baseUrl/notifications?expand=report',
      ).replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load notification detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching notification detail: $e');
    }
  }

  // /// Get all notifications
  // Future<Map<String, dynamic>> getNotifications({
  //   int page = 1,
  //   int perPage = 10,
  // }) async {
  //   try {
  //     final token = await _getAuthToken();
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/v1/notifications?page=$page&per_page=$perPage'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       return json.decode(response.body) as Map<String, dynamic>;
  //     } else {
  //       throw Exception('Failed to load notifications: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching notifications: $e');
  //   }
  // }

  /// Get unread notifications count
  /// Get unread notifications count
  Future<Map<String, dynamic>> getUnreadCount() async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl/notifications/unread/count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Treat 200 => parse; 204 or 404 => return zero; otherwise throw
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 204 || response.statusCode == 404) {
        // Backend says "no resource" or "no content": treat as zero unread
        return {
          'success': true,
          'data': {'unread_count': 0},
        };
      } else {
        // log body for debugging
        debugPrint(
          'getUnreadCount failed: ${response.statusCode} ${response.body}',
        );
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting unread count: $e');
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to mark as read: ${response.statusCode}');
    }
  }

  /// Delete notification
  Future<Map<String, dynamic>> deleteNotification(String notificationId) async {
    final token = await _getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to delete notification: ${response.statusCode}');
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>> markAllAsRead() async {
    final token = await _getAuthToken();
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to mark all as read: ${response.statusCode}');
    }
  }

  /// Clear all notifications
  Future<Map<String, dynamic>> clearAllNotifications() async {
    final token = await _getAuthToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/clear-all'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Failed to clear all notifications: ${response.statusCode}',
      );
    }
  }
}
