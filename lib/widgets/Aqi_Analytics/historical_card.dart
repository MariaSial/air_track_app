// Historical data card widget
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';

Widget HistoricalCard({
  required DateTime dateTime,
  required int aqiValue,
  required double pm2_5,
  required double pm10,
  required double no2,
  required double so2,
  required double co,
  required double o3,
}) {
  // Get AQI color and label
  Color aqiColor;
  String aqiLabel;

  if (aqiValue >= 0 && aqiValue <= 50) {
    aqiColor = Colors.green;
    aqiLabel = 'Good';
  } else if (aqiValue >= 51 && aqiValue <= 100) {
    aqiColor = Colors.yellow[700]!;
    aqiLabel = 'Moderate';
  } else if (aqiValue >= 101 && aqiValue <= 150) {
    aqiColor = Colors.orange;
    aqiLabel = 'Unhealthy for Sensitive';
  } else if (aqiValue >= 151 && aqiValue <= 200) {
    aqiColor = Colors.red;
    aqiLabel = 'Unhealthy';
  } else if (aqiValue >= 201 && aqiValue <= 300) {
    aqiColor = Colors.purple;
    aqiLabel = 'Very Unhealthy';
  } else {
    aqiColor = Colors.brown;
    aqiLabel = 'Hazardous';
  }

  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: aqiColor.withOpacity(0.3), width: 2),
      boxShadow: [
        BoxShadow(
          color: black.withOpacity(0.05),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and Time
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: grey),
                SizedBox(width: 8),
                Text(
                  _formatHistoricalDate(dateTime),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: black,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: aqiColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                aqiLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: aqiColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // AQI Value
        Row(
          children: [
            Text('AQI: ', style: TextStyle(fontSize: 16, color: grey)),
            Text(
              aqiValue.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: aqiColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),

        // Pollutants in compact view
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildPollutantChip('PM2.5', pm2_5.toStringAsFixed(1)),
            _buildPollutantChip('PM10', pm10.toStringAsFixed(1)),
            _buildPollutantChip('NO₂', no2.toStringAsFixed(1)),
            _buildPollutantChip('SO₂', so2.toStringAsFixed(1)),
            _buildPollutantChip('CO', co.toStringAsFixed(1)),
            _buildPollutantChip('O₃', o3.toStringAsFixed(1)),
          ],
        ),
      ],
    ),
  );
}

// Pollutant chip widget
Widget _buildPollutantChip(String name, String value) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.cyan.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '$name: $value',
      style: TextStyle(fontSize: 11, color: black, fontWeight: FontWeight.w500),
    ),
  );
}

// Format date for historical view
String _formatHistoricalDate(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inDays == 0) {
    return 'Today';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    // Show day of week
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[dateTime.weekday - 1];
  } else {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
