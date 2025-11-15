// lib/widgets/aqi_bottom_nav_bar.dart
import 'package:air_track_app/view/authentication/contactus_view.dart';
import 'package:air_track_app/view/authentication/sign_in_view.dart';
import 'package:air_track_app/view/notifications/notification_view.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:air_track_app/view/aqi_analytics/aqi_analytics_view.dart';
import 'package:air_track_app/view/report_status/reports_view.dart';

class AqiBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AqiBottomNavBar({Key? key, required this.currentIndex})
    : super(key: key);

  void _navigateToPage(BuildContext context, int index) {
    Widget destination;

    switch (index) {
      case 0:
        destination = const SignInView();
        break;
      case 1:
        destination = const AqiAnalyticsView();
        break;
      case 2:
        destination = const ReportsView();
        break;
      case 3:
        destination = const NotificationView();
        break;
      default:
        destination = const SignInView();
    }

    // Replace the current route so the nav bar updates properly
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: blue,
        boxShadow: [
          BoxShadow(color: black, blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, 'Home', 0),
              _buildNavItem(context, Icons.air, 'AQI Analytics', 1),
              _buildNavItem(context, Icons.article, 'My Reports', 2),
              _buildNavItem(context, Icons.notifications, 'Notifications', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => _navigateToPage(context, index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? black : white, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? black : white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
