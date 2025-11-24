// lib/widgets/reports/report_card.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/services/report_service.dart';

class ReportCard extends StatelessWidget {
  final String? imageUrl;
  final int? reportId;
  final String location;
  final String date;
  final String time;
  final String reporterName;
  final String status;
  final VoidCallback? onTap;
  final String? hostOverride;

  const ReportCard({
    super.key,
    this.imageUrl,
    this.reportId,
    required this.location,
    required this.date,
    required this.time,
    required this.reporterName,
    required this.status,
    this.onTap,
    this.hostOverride,
  });

  Color _statusColor(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('accept')) return green;
    if (lower.contains('pend')) return orange;
    if (lower.contains('reject') || lower.contains('decline')) return red;
    return black;
  }

  Widget _placeholder() {
    print('  🖼️ Showing placeholder (no image)');
    return Container(
      width: 120,
      height: 80,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }

  Widget _imageWidget() {
    print('🎨 ReportCard._imageWidget called');
    print('  imageUrl: "$imageUrl"');
    print('  reportId: $reportId');
    print('  hostOverride: $hostOverride');

    // If no image URL is provided, show placeholder immediately
    if ((imageUrl == null || imageUrl!.trim().isEmpty) && reportId == null) {
      print('  ❌ No imageUrl and no reportId -> showing placeholder');
      return _placeholder();
    }

    // If we have an imageUrl, try to load it
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final normalized = _normalize(imageUrl!, hostOverride);
      print('  🌐 Attempting Image.network with normalized URL: "$normalized"');

      return Image.network(
        normalized,
        width: 120,
        height: 80,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('  ✅ Image loaded successfully from network');
            return child;
          }
          print(
            '  ⏳ Loading image... ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes ?? "?"} bytes',
          );
          return SizedBox(
            width: 120,
            height: 80,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('  ❌ Image.network failed: $error');

          // If network image fails and we have reportId, try authenticated fetch
          if (reportId != null) {
            print('  🔄 Trying authenticated fetch with reportId: $reportId');
            return FutureBuilder<Uint8List>(
              future: ReportService.getReportMediaBytes(
                reportId: reportId,
                mediaUrl: imageUrl,
                overrideHost: hostOverride,
              ),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  print('  ⏳ Fetching authenticated media...');
                  return SizedBox(
                    width: 120,
                    height: 80,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                if (snap.hasError) {
                  print('  ❌ Authenticated fetch error: ${snap.error}');
                }
                if (snap.hasData &&
                    snap.data != null &&
                    snap.data!.isNotEmpty) {
                  print(
                    '  ✅ Got ${snap.data!.length} bytes from authenticated fetch',
                  );
                  return Image.memory(
                    snap.data!,
                    width: 120,
                    height: 80,
                    fit: BoxFit.cover,
                  );
                }
                print('  ❌ Authenticated fetch returned no data');
                return _placeholder();
              },
            );
          }
          return _placeholder();
        },
      );
    }

    print('  ❌ No valid imageUrl -> showing placeholder');
    return _placeholder();
  }

  String _normalize(String raw, String? hostOverride) {
    print('  🔧 Normalizing URL: "$raw"');

    try {
      final u = Uri.parse(raw);
      final host = u.host.toLowerCase();
      if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
        final scheme = u.scheme.isEmpty ? 'http' : u.scheme;
        final pathAndQuery = '${u.path}${u.hasQuery ? '?${u.query}' : ''}';

        if (hostOverride != null && hostOverride.isNotEmpty) {
          return '$scheme://$hostOverride$pathAndQuery';
        } else {
          // Default emulator host mapping
          return '$scheme://10.0.2.2$pathAndQuery';
        }
      }
    } catch (_) {
      // fallthrough to contains check
    }

    // Fallback simple contains replacement
    if (raw.contains('localhost')) {
      if (hostOverride?.isNotEmpty ?? false) {
        final result = raw.replaceFirst('localhost', hostOverride!);
        print('    → Replaced localhost with override: "$result"');
        return result;
      }
      final result = raw.replaceFirst('localhost', '10.0.2.2');
      print('    → Replaced localhost with emulator IP: "$result"');
      return result;
    }

    print('    → No changes needed');
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: blue, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 120,
                      height: 80,
                      child: _imageWidget(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "Date: $date",
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Time: $time",
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Reporter: $reporterName",
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _statusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
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
