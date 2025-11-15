import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class NotificationDetailView extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailView({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    // If the API returned expanded report in notification['data']['report'] or notification['report']
    final report =
        (notification['data'] is Map && notification['data']['report'] != null)
        ? notification['data']['report'] as Map<String, dynamic>
        : (notification['report'] is Map
              ? notification['report'] as Map<String, dynamic>
              : null);

    final imageUrl = notification['image'] ?? report?['image_url'];

    final title =
        notification['title'] ?? notification['message'] ?? 'Notification';
    final message = notification['message'] ?? '';

    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: "Notification Details"),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // image (network if provided, else asset)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl.toString(),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Image.asset(reportcard),
                                )
                              : Image.asset(reportcard),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title & message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message,
                              style: const TextStyle(fontSize: 16, height: 1.4),
                            ),
                            const SizedBox(height: 12),

                            // If report exists, show some report fields
                            if (report != null) ...[
                              const Divider(),
                              Text(
                                'Report details',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (report['location'] != null)
                                Text('Location: ${report['location']}'),
                              if (report['status'] != null)
                                Text('Status: ${report['status']}'),
                              if (report['id'] != null)
                                Text('Report id: ${report['id']}'),
                              // show more fields as available
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
