import 'package:air_track_app/model/air_quality_data_model.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';

// FORECAST CARD WIDGET

class ForecastCard extends StatelessWidget {
  final ForecastDay day;

  const ForecastCard({super.key, required this.day});

  // Determine the color based on the max AQI value (simplified)
  Color _getForecastColor(int aqi) {
    if (aqi > 150) return const Color(0xFFE57373); // Light Red
    if (aqi > 100) return const Color(0xFFFFCC80); // Light Orange
    if (aqi > 50) return const Color(0xFFA5D6A7); // Light Green
    return const Color(0xFF64B5F6); // Light Blue
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = _getForecastColor(day.maxAqi);

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(day.day, style: kTextTheme.titleLarge?.copyWith(fontSize: 16)),
          Text(day.date, style: kTextTheme.bodyMedium),
          const Spacer(),
          Center(
            child: Text(
              '${day.minAqi}-${day.maxAqi}',
              style: kTextTheme.headlineMedium?.copyWith(color: cardColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AQI Range',
            style: kTextTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
