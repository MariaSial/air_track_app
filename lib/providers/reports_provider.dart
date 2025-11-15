// lib/providers/report_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:air_track_app/services/auth_storage.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;

class ReportsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  ReportsNotifier() : super(const AsyncValue.loading()) {
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      state = const AsyncValue.loading();
      final token = await AuthStorage.getToken();
      if (token == null) {
        state = AsyncValue.error("You are not logged in.", StackTrace.current);
        return;
      }

      final response = await http.get(
        Uri.parse("https://testproject.famzhost.com/api/v1/my-reports"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        state = AsyncValue.data(data);
      } else if (response.statusCode == 401) {
        state = AsyncValue.error(
          "Unauthorized — please sign in again.",
          StackTrace.current,
        );
      } else {
        state = AsyncValue.error(
          "Failed to load reports (${response.statusCode})",
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> refreshReports() async => fetchReports();
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<List<dynamic>>>(
      (ref) => ReportsNotifier(),
    );
