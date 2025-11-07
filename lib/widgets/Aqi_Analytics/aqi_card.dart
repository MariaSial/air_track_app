import 'dart:math' as math;

import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class AqiCard extends StatelessWidget {
  final int aqiValue;
  final String locationName;
  const AqiCard({
    super.key,
    required this.aqiValue,
    required this.locationName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Container(
        // height: MediaQuery.sizeOf(context).height * 0.54,
        // width: MediaQuery.sizeOf(context).height * 0.82,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your location',
              style: TextStyle(
                fontSize: 12,
                color: grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              locationName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: black,
              ),
            ),
            const SizedBox(height: 60),
            Center(child: AQIGauge(value: aqiValue)),
          ],
        ),
      ),
    );
  }
}

// AQI Data Model
class AQIData {
  final Color color;
  final String label;

  AQIData({required this.color, required this.label});

  static AQIData getAQIData(int value) {
    if (value >= 0 && value <= 50) {
      return AQIData(color: green, label: 'Good');
    } else if (value >= 51 && value <= 100) {
      return AQIData(color: yellow, label: 'Moderate');
    } else if (value >= 101 && value <= 150) {
      return AQIData(color: orange, label: 'Unhealthy for Sensitive Groups');
    } else if (value >= 151 && value <= 200) {
      return AQIData(color: red, label: 'Unhealthy');
    } else if (value >= 201 && value <= 300) {
      return AQIData(color: purple, label: 'Very Unhealthy');
    } else {
      // 301 and higher
      return AQIData(color: maroon, label: 'Hazardous');
    }
  }
}

// Custom AQI Gauge Widget
class AQIGauge extends StatelessWidget {
  final int value;

  const AQIGauge({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final aqiData = AQIData.getAQIData(value);

    return Column(
      children: [
        SizedBox(
          width: 160,
          height: 80,
          child: CustomPaint(
            painter: AQIGaugePainter(value: value, color: aqiData.color),
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: black,
                ),
              ),
            ),
          ),
        ),
        // const SizedBox(height: 4),
        Text(
          aqiData.label,
          style: TextStyle(
            fontSize: aqiData.label.length > 10 ? 14 : 16,
            fontWeight: FontWeight.w500,
            color: aqiData.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class AQIGaugePainter extends CustomPainter {
  final int value;
  final Color color;

  AQIGaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Foreground arc (progress) with conditional color
    final foregroundPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (value / 500) * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
