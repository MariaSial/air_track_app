import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:flutter/material.dart';

class AqiStatusMessage extends StatelessWidget {
  final int aqiValue;

  const AqiStatusMessage({super.key, required this.aqiValue});

  @override
  Widget build(BuildContext context) {
    final statusData = AQIStatusData.getStatusData(aqiValue);

    final bool isAlert = aqiValue > 150;
    final Color textColor = isAlert ? red : black;
    final IconData icon = isAlert
        ? Icons.warning_amber_rounded
        : statusData.icon;
    final Color iconColor = isAlert ? red : statusData.color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: grey.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Optional: Add an icon based on AQI level
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(
            statusData.message,
            style: TextStyle(fontSize: 14, color: textColor, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// AQI Status Data Model
class AQIStatusData {
  final String message;
  final Color color;
  final IconData icon;

  AQIStatusData({
    required this.message,
    required this.color,
    required this.icon,
  });

  static AQIStatusData getStatusData(int value) {
    if (value >= 0 && value <= 50) {
      // Good
      return AQIStatusData(
        message: goodAqi,
        color: green,
        icon: Icons.check_circle_outline,
      );
    } else if (value >= 51 && value <= 100) {
      // Moderate
      return AQIStatusData(
        message: moderateAqi,
        color: yellow,
        icon: Icons.info_outline,
      );
    } else if (value >= 101 && value <= 150) {
      // Unhealthy for Sensitive Groups
      return AQIStatusData(
        message: sensitiveaqi,
        color: orange,
        icon: Icons.error_outline,
      );
    } else if (value >= 151 && value <= 200) {
      // Unhealthy
      return AQIStatusData(
        message: unhealthy,
        color: red,
        icon: Icons.error_outline,
      );
    } else if (value >= 201 && value <= 300) {
      // Very Unhealthy
      return AQIStatusData(
        message: veryUnhealthy,
        color: purple,
        icon: Icons.dangerous_outlined,
      );
    } else {
      // Hazardous (301 and higher)
      return AQIStatusData(
        message: hazardous,
        color: maroon,
        icon: Icons.cancel_outlined,
      );
    }
  }
}

// Alternative version without icon if you prefer the original layout
class AqiStatusMessageSimple extends StatelessWidget {
  final int aqiValue;

  const AqiStatusMessageSimple({super.key, required this.aqiValue});

  @override
  Widget build(BuildContext context) {
    final statusData = AQIStatusData.getStatusData(aqiValue);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: grey.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        statusData.message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
