import 'package:flutter/material.dart';
import 'package:air_track_app/widgets/app_colors.dart'; // optional if you use custom colors

class ReportCard extends StatelessWidget {
  final String imageUrl;
  final String location;
  final String date;
  final String time;
  final String reporterName;
  final String status;

  const ReportCard({
    super.key,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.time,
    required this.reporterName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: blue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.1),
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
            /// Row: Image + Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 120,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),

                // Right: Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: black),
                          const SizedBox(width: 4),
                          Text(
                            location,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("Date: $date", style: const TextStyle(fontSize: 12)),
                      Text("Time: $time", style: const TextStyle(fontSize: 12)),
                      Text(
                        "Reporter’s Name: $reporterName",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Status (bottom text)
            Center(
              child: Text(
                status,
                style: TextStyle(
                  color: status == "Accepted"
                      ? green
                      : status == "Pending"
                      ? orange
                      : red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
