// lib/view/reports/reports_view.dart
import 'package:air_track_app/providers/reports_provider.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_bottom_nav_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/reports/report_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsView extends ConsumerWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);

    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: 'My Reports'),

              // Expanded List area
              Expanded(
                child: reportsAsync.when(
                  data: (reports) {
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
                          final report = reports[index];

                          // Parse date/time
                          DateTime? createdAt;
                          try {
                            createdAt = DateTime.parse(report['created_at']);
                          } catch (_) {}

                          final date = createdAt != null
                              ? "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}"
                              : "--/--/----";
                          final time = createdAt != null
                              ? "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}"
                              : "--:--";

                          return ReportCard(
                            imageUrl:
                                (report['media_url'] != null &&
                                    report['media_url'].toString().isNotEmpty)
                                ? report['media_url']
                                : "https://via.placeholder.com/150",
                            location: report['location'] ?? "Unknown area",
                            date: date,
                            time: time,
                            reporterName:
                                "Reporter #${report['user_id'] ?? '-'}",
                            status: (report['status'] ?? "pending")
                                .toString()
                                .toUpperCase(),
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
                      child: Text(
                        err.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
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
