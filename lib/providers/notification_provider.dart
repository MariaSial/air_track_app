// lib/providers/notification_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:air_track_app/services/notification_serviceapi.dart';
import 'package:air_track_app/services/auth_storage.dart';
import 'package:air_track_app/model/notification_model.dart';
import 'package:flutter_riverpod/legacy.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationProvider extends ChangeNotifier {
  final Ref ref;
  NotificationProvider(this.ref);

  // state
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  NotificationService get _service => ref.read(notificationServiceProvider);

  Future<void> init() async {
    await Future.wait([loadNotifications(), loadUnreadCount()]);
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _notifications = [];
      _errorMessage = null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await AuthStorage.getToken();
      if (token == null || token.isEmpty) {
        _isLoading = false;
        _errorMessage = "You are not logged in. Please sign in again.";
        notifyListeners();
        return;
      }

      final rawResponse = await _service.getNotifications();
      final Map<String, dynamic> resp = rawResponse as Map<String, dynamic>;

      List<dynamic> rawList = [];
      if (resp['data'] is List) {
        rawList = resp['data'] as List<dynamic>;
      } else if (resp['data'] is Map && resp['data']['notifications'] is List) {
        rawList = resp['data']['notifications'] as List<dynamic>;
      }

      final fetchedNotifs = rawList
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .map((model) => model.toAppFormat())
          .toList();

      _notifications = fetchedNotifs;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      final s = e.toString().toLowerCase();
      if (s.contains('auth token')) {
        _errorMessage = "You are not logged in. Please sign in again.";
      } else if (s.contains('404') ||
          s.contains('204') ||
          s.contains('no data')) {
        _errorMessage = null; // treat as empty list
        _notifications = [];
      } else {
        _errorMessage = "Failed to load notifications ($e)";
      }
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null || token.isEmpty) {
        _unreadCount = 0;
        notifyListeners();
        return;
      }

      final rawResponse = await _service.getUnreadCount();
      final Map<String, dynamic> resp = rawResponse as Map<String, dynamic>;
      _unreadCount =
          (resp['data'] as Map<String, dynamic>?)?['unread_count'] ?? 0;
      notifyListeners();
    } catch (e) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await Future.wait([loadNotifications(refresh: true), loadUnreadCount()]);
  }

  Future<bool> markAsRead(String notifId, {int? index}) async {
    try {
      await _service.markAsRead(notifId);
      if (index != null && index >= 0 && index < _notifications.length) {
        _notifications[index]['isRead'] = true;
      }
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(String notifId, {int? index}) async {
    try {
      await _service.deleteNotification(notifId);
      if (index != null && index >= 0 && index < _notifications.length) {
        if (!_notifications[index]['isRead'] && _unreadCount > 0)
          _unreadCount--;
        _notifications.removeAt(index);
      } else {
        // fallback: remove by id
        _notifications.removeWhere((n) => n['id'] == notifId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // optional local helpers
  void muteNotificationAt(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index]['isMuted'] = true;
      notifyListeners();
    }
  }
}

final notificationProvider = ChangeNotifierProvider<NotificationProvider>((
  ref,
) {
  return NotificationProvider(ref);
});
