// lib/view/report_status/details_report_view.dart
import 'dart:typed_data';
import 'package:air_track_app/view/report_status/reports_view.dart';
import 'package:flutter/material.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/services/report_service.dart';

class DetailReportView extends StatelessWidget {
  final Map report;
  final String? hostOverride = ReportsView.kHostOverride;

  const DetailReportView({
    super.key,
    required this.report,
    String? hostOverride,
  });

  String _extractImageUrl(Map report) {
    // Priority 1: Check media array
    if (report['media'] is List && (report['media'] as List).isNotEmpty) {
      final mediaList = report['media'] as List;
      final first = mediaList.first;
      if (first is Map) {
        if (first['original_url'] is String &&
            (first['original_url'] as String).trim().isNotEmpty) {
          return first['original_url'] as String;
        }
        if (first['url'] is String &&
            (first['url'] as String).trim().isNotEmpty) {
          return first['url'] as String;
        }
      }
    }

    // Priority 2: Check media_url
    if (report.containsKey('media_url') &&
        report['media_url'] is String &&
        (report['media_url'] as String).trim().isNotEmpty) {
      return report['media_url'] as String;
    }

    // Priority 3: Other fields
    if (report.containsKey('photo') &&
        report['photo'] is String &&
        (report['photo'] as String).trim().isNotEmpty) {
      return report['photo'] as String;
    }

    // Priority 4: Nested data
    if (report['data'] is Map) {
      final data = report['data'] as Map;
      if (data['media_url'] is String &&
          (data['media_url'] as String).trim().isNotEmpty) {
        return data['media_url'] as String;
      }
    }

    return "";
  }

  String _normalize(String raw) {
    if (raw.contains('localhost')) {
      if (hostOverride?.isNotEmpty ?? false) {
        return raw.replaceFirst('localhost', hostOverride!);
      }
      return raw.replaceFirst('localhost', '10.0.2.2');
    }
    return raw;
  }

  Widget _buildImage(String imageUrl, int? reportId) {
    if (imageUrl.isEmpty && reportId == null) {
      return Container(
        width: double.infinity,
        height: 240,
        color: Colors.grey[200],
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_not_supported, size: 56, color: Colors.grey),
            SizedBox(height: 8),
            Text('No image available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (imageUrl.isNotEmpty) {
      final normalized = _normalize(imageUrl);

      return Image.network(
        normalized,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 240,
            color: Colors.grey[100],
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Try authenticated fetch if network fails and we have reportId
          if (reportId != null) {
            return FutureBuilder<Uint8List>(
              future: ReportService.getReportMediaBytes(
                reportId: reportId,
                mediaUrl: imageUrl,
                overrideHost: hostOverride,
              ),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    height: 240,
                    color: Colors.grey[100],
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
                if (snap.hasData &&
                    snap.data != null &&
                    snap.data!.isNotEmpty) {
                  return Image.memory(
                    snap.data!,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                  );
                }
                return Container(
                  width: double.infinity,
                  height: 240,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.broken_image, size: 56, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Container(
            width: double.infinity,
            height: 240,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.broken_image, size: 56, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      width: double.infinity,
      height: 240,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        size: 56,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _extractImageUrl(report);
    final reportId = report['id'] != null
        ? int.tryParse(report['id'].toString())
        : null;

    DateTime? createdAt;
    try {
      createdAt = DateTime.parse(report['created_at']?.toString() ?? '');
    } catch (_) {}

    final date = createdAt != null
        ? "${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}"
        : "--/--/----";

    final time = createdAt != null
        ? "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}"
        : "--:--";

    final statusStr = (report['status'] ?? 'pending').toString().toLowerCase();
    final statusColor = statusStr == 'accepted'
        ? green
        : statusStr == 'pending'
        ? orange
        : red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: blue,
        title: Text(report['title']?.toString() ?? "Report Detail"),
        foregroundColor: white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(imageUrl, reportId),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              report['title']?.toString() ?? "No title",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.air_rounded,
              label: "Pollution Type",
              value: report['pollution_type'] ?? '-',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.description,
              label: "Description",
              value: report['description'] ?? '-',
              isMultiline: true,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.location_on,
              label: "Location",
              value: report['location'] ?? '-',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.person,
              label: "Reporter ID",
              value: report['user_id']?.toString() ?? '-',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Colors.black54),
                const SizedBox(width: 8),
                const Text(
                  "Status: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusStr.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Submitted on: $date at $time",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            // Show media attachments info if available
            if (report['media'] is List &&
                (report['media'] as List).isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Attachments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              for (final m in (report['media'] as List))
                if (m is Map)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          _getFileIcon(m['mime_type']?.toString()),
                          color: blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['file_name']?.toString() ?? 'file',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                m['mime_type']?.toString() ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.attach_file;
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    return Icons.attach_file;
  }
}
