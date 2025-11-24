// lib/view/reports/reports_view.dart
import 'package:air_track_app/providers/reports_provider.dart';
import 'package:air_track_app/view/report_status/details_report_view.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_bottom_nav_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/reports/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  // IMPORTANT: Set this to your machine's IP when testing on real device
  // Example: '192.168.1.10:8000' or 'abcd.ngrok.io' (without http://)
  static const String? kHostOverride =
      null; // <-- CHANGE THIS for real device testing

  String _extractImageUrl(Map report) {
    print('🔍 Extracting image URL for report ID: ${report['id']}');

    // Priority 1: Check media array for uploaded images
    if (report['media'] is List && (report['media'] as List).isNotEmpty) {
      print(
        '✓ Found media array with ${(report['media'] as List).length} items',
      );
      final mediaList = report['media'] as List;
      final first = mediaList.first;

      if (first is Map) {
        print('  Media item keys: ${first.keys.toList()}');

        // Try original_url first
        if (first['original_url'] is String &&
            (first['original_url'] as String).trim().isNotEmpty) {
          final url = first['original_url'] as String;
          print('  ✓ Using original_url: $url');
          return url;
        }

        // Fallback to other URL fields
        if (first['url'] is String &&
            (first['url'] as String).trim().isNotEmpty) {
          final url = first['url'] as String;
          print('  ✓ Using url: $url');
          return url;
        }
      }
    } else {
      print('✗ No media array found or empty');
    }

    // Priority 2: Check media_url field
    if (report.containsKey('media_url') &&
        report['media_url'] is String &&
        (report['media_url'] as String).trim().isNotEmpty) {
      final url = report['media_url'] as String;
      print('✓ Using media_url: $url');
      return url;
    } else {
      print('✗ media_url is empty or null: ${report['media_url']}');
    }

    // Priority 3: Check other common image field names
    final candidates = ['photo', 'image', 'file', 'image_url', 'photo_url'];

    for (final k in candidates) {
      if (report.containsKey(k) &&
          report[k] is String &&
          (report[k] as String).trim().isNotEmpty) {
        final url = report[k] as String;
        print('✓ Using $k: $url');
        return url;
      }
    }

    // Priority 4: Check nested data object
    if (report['data'] is Map) {
      final data = report['data'] as Map;
      if (data['media_url'] is String &&
          (data['media_url'] as String).trim().isNotEmpty) {
        final url = data['media_url'] as String;
        print('✓ Using data.media_url: $url');
        return url;
      }
    }

    print('✗ No image URL found for this report');
    return "";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              const AqiAppBar(title: 'My Reports'),
              Expanded(
                child: reportsAsync.when(
                  data: (reports) {
                    print('📊 Total reports loaded: ${reports.length}');

                    if (reports.isEmpty) {
                      return const Center(
                        child: Text(
                          'No reports are registered yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(reportsProvider.notifier).refreshReports(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final raw = reports[index];
                          final Map<String, dynamic> report = (raw is Map)
                              ? Map<String, dynamic>.from(raw)
                              : {};

                          print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
                          print('Building card for report #${index + 1}');
                          print('Report ID: ${report['id']}');

                          DateTime? createdAt;
                          try {
                            createdAt = DateTime.parse(
                              report['created_at']?.toString() ?? '',
                            );
                          } catch (_) {}

                          final date = createdAt != null
                              ? "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}"
                              : "--/--/----";

                          final time = createdAt != null
                              ? "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}"
                              : "--:--";

                          final imageUrl = _extractImageUrl(report);
                          final id = report['id'] != null
                              ? int.tryParse(report['id'].toString())
                              : null;

                          print('Final imageUrl: "$imageUrl"');
                          print('Report ID for fetch: $id');
                          print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

                          return ReportCard(
                            reportId: id,
                            imageUrl: imageUrl,
                            hostOverride: kHostOverride,
                            location:
                                report['location']?.toString() ??
                                "Unknown area",
                            date: date,
                            time: time,
                            reporterName:
                                "Reporter #${report['user_id'] ?? '-'}",
                            status: (report['status'] ?? "pending")
                                .toString()
                                .toUpperCase(),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailReportView(
                                  report: report,
                                  hostOverride: kHostOverride,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            err.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref
                                .read(reportsProvider.notifier)
                                .refreshReports(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AqiBottomNavBar(currentIndex: 2),
    );
  }
}
