import 'dart:convert';
import 'package:air_track_app/services/auth_storage.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_bottom_nav_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/reports/report_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  List<dynamic> reports = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final token = await AuthStorage.getToken(); // ✅ Fetch saved token

      if (token == null) {
        setState(() {
          errorMessage = "You are not logged in. Please sign in again.";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
          "https://testproject.famzhost.com/api/v1/my-reports",
        ), // 🔁 Replace with your actual endpoint
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token", // ✅ attach token here
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          reports = data;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = "Unauthorized (401) — Please sign in again.";
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "Failed to load reports (${response.statusCode}): ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching reports: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: 'My Reports'),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: red),
                          ),
                        ),
                      )
                    : reports.isEmpty
                    ? Center(
                        child: Text(
                          'No reports are registered yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: black,
                          ),
                        ),
                      )
                    : ListView.builder(
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
                            imageUrl: report['media_url'].isNotEmpty
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
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AqiBottomNavBar(currentIndex: 2),
    );
  }
}
