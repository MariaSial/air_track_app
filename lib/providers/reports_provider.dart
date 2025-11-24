// lib/providers/reports_provider.dart
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

      final uri = Uri.parse(
        "https://testproject.famzhost.com/api/v1/my-reports",
      );
      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Debug logs
      print('═══════════════════════════════════════');
      print('fetchReports - status: ${response.statusCode}');
      print('fetchReports - body length: ${response.body.length}');
      print('fetchReports - raw body: "${response.body}"');
      print('═══════════════════════════════════════');

      if (response.statusCode == 200) {
        final bodyTrim = response.body.trim();
        if (bodyTrim.isEmpty) {
          state = AsyncValue.data([]);
          return;
        }

        final decoded = json.decode(bodyTrim);
        List reportsList;

        // If server returns { "data": [...] }
        if (decoded is Map && decoded['data'] is List) {
          reportsList = decoded['data'] as List;
        }
        // If server returns the list directly: [ {...}, {...} ]
        else if (decoded is List) {
          reportsList = decoded;
        } else if (decoded is Map && decoded['message'] != null) {
          reportsList = [];
        } else {
          reportsList = [];
        }

        // Debug: Print first report details if available
        if (reportsList.isNotEmpty) {
          print('─────────────────────────────────────');
          print('First report data:');
          print(json.encode(reportsList.first));
          print('─────────────────────────────────────');

          final firstReport = reportsList.first;
          if (firstReport is Map) {
            print('Keys in first report: ${firstReport.keys.toList()}');
            print('media_url: ${firstReport['media_url']}');
            print('photo: ${firstReport['photo']}');
            print('media: ${firstReport['media']}');
            if (firstReport['media'] is List &&
                (firstReport['media'] as List).isNotEmpty) {
              print('First media item:');
              print(json.encode((firstReport['media'] as List).first));
            }
          }
          print('─────────────────────────────────────');
        }

        state = AsyncValue.data(reportsList);
      } else if (response.statusCode == 401) {
        state = AsyncValue.error(
          "Unauthorized — please sign in again.",
          StackTrace.current,
        );
      } else {
        String serverMsg = 'Failed to load reports (${response.statusCode})';
        try {
          final bodyTrim = response.body.trim();
          if (bodyTrim.isNotEmpty) {
            final decoded = json.decode(bodyTrim);
            if (decoded is Map && decoded['message'] != null)
              serverMsg = decoded['message'].toString();
          }
        } catch (_) {}
        state = AsyncValue.error(serverMsg, StackTrace.current);
      }
    } catch (e, st) {
      print('ERROR in fetchReports: $e');
      print('Stack trace: $st');
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> refreshReports() async => fetchReports();

  Future<void> deleteReport(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Invalid report id');
    }

    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('You are not logged in.');
    }

    final base = 'https://testproject.famzhost.com/api/v1/my-reports';
    final uri = Uri.parse('$base/$id');
    final response = await http.delete(
      uri,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print('deleteReport - url: $uri');
    print('deleteReport - status: ${response.statusCode}');
    print('deleteReport - body: "${response.body}"');

    if (response.statusCode == 200 || response.statusCode == 204) {
      final current = state;
      if (current is AsyncData<List<dynamic>>) {
        final list = List.from(current.value);
        list.removeWhere((r) => _matchesId(r, id));
        state = AsyncValue.data(list);
      } else {
        await fetchReports();
      }
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized — please sign in again.');
    } else if (response.statusCode == 404) {
      throw Exception('Report not found (404).');
    } else {
      String serverMsg = 'Failed to delete report (${response.statusCode})';
      try {
        final bodyTrim = response.body.trim();
        if (bodyTrim.isNotEmpty) {
          final decoded = json.decode(bodyTrim);
          if (decoded is Map && decoded['message'] != null) {
            serverMsg = decoded['message'].toString();
          }
        }
      } catch (_) {}
      throw Exception(serverMsg);
    }
  }

  Future<dynamic> deleteReportLocalOnly(String id) async {
    if (id.trim().isEmpty) {
      throw Exception('Invalid report id');
    }

    final current = state;
    if (current is! AsyncData<List<dynamic>>) {
      throw Exception('Reports not loaded yet.');
    }

    final list = List.from(current.value);
    final idx = list.indexWhere((r) => _matchesId(r, id));
    if (idx == -1) {
      throw Exception('Report not found locally.');
    }

    final removed = list.removeAt(idx);
    state = AsyncValue.data(list);
    return removed;
  }

  Future<void> restoreReportLocal(dynamic report) async {
    if (report == null) return;
    final current = state;
    if (current is AsyncData<List<dynamic>>) {
      final list = List.from(current.value);
      final id = _extractId(report);
      if (id != null && list.any((r) => _matchesId(r, id))) {
        return;
      }
      list.insert(0, report);
      state = AsyncValue.data(list);
    } else {
      await fetchReports();
    }
  }

  String? _extractId(dynamic report) {
    if (report == null) return null;
    final idCandidates = [
      'id',
      '_id',
      'report_id',
      'reportId',
      'id_str',
      'uuid',
    ];
    if (report is Map) {
      for (final k in idCandidates) {
        if (report.containsKey(k) && report[k] != null)
          return report[k].toString();
      }
      if (report['data'] is Map) {
        final dataMap = report['data'] as Map;
        for (final k in idCandidates) {
          if (dataMap.containsKey(k) && dataMap[k] != null)
            return dataMap[k].toString();
        }
      }
    }
    return null;
  }

  bool _matchesId(dynamic report, String idStr) {
    if (report == null) return false;
    final candidates = ['id', '_id', 'report_id', 'reportId', 'id_str', 'uuid'];
    final target = idStr.toString();
    if (report is Map) {
      for (final key in candidates) {
        if (report.containsKey(key) && report[key] != null) {
          if (report[key].toString() == target) return true;
        }
      }
      if (report['data'] is Map) {
        final dataMap = report['data'] as Map;
        for (final key in candidates) {
          if (dataMap.containsKey(key) && dataMap[key] != null) {
            if (dataMap[key].toString() == target) return true;
          }
        }
      }
      if (report['attributes'] is Map) {
        final attrs = report['attributes'] as Map;
        for (final key in candidates) {
          if (attrs.containsKey(key) && attrs[key] != null) {
            if (attrs[key].toString() == target) return true;
          }
        }
      }
    }
    if (report.toString() == target) return true;
    return false;
  }
}

final reportsProvider =
    StateNotifierProvider<ReportsNotifier, AsyncValue<List<dynamic>>>(
      (ref) => ReportsNotifier(),
    );
