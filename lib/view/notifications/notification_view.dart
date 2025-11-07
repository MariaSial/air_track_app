import 'package:air_track_app/view/notifications/notification_detail_view.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_bottom_nav_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<Map<String, dynamic>> notifications = [
    {
      "id": 1,
      "title": "Your report from DI Khan is accepted",
      "image": "assets/images/fire.jpg",
      "time": "20m",
      "isRead": false,
      "isMuted": false,
    },
  ];

  void _onMenuSelected(String value, int index) {
    switch (value) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                NotificationDetailView(notification: notifications[index]),
          ),
        );
        break;

      case 'mute':
        setState(() {
          notifications[index]['isMuted'] = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification muted')));
        break;

      case 'delete':
        setState(() {
          notifications.removeAt(index);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification deleted')));
        break;

      case 'read':
        setState(() {
          notifications[index]['isRead'] = true;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Marked as read')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: "Notifications"),
              Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            reportcard,
                            // width: 60,
                            // height: 60,
                            // fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          notif['title'],
                          style: TextStyle(
                            fontWeight: notif['isRead']
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(notif['time']),
                        trailing: PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: black),
                          color: white, // default popup background
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: lightgrey),
                          ),
                          onSelected: (value) => _onMenuSelected(value, index),
                          itemBuilder: (context) => [
                            _buildPopupItem(
                              'view',
                              'View Details',
                              Icons.description,
                            ),
                            _buildPopupItem(
                              'mute',
                              'Mute Notification',
                              Icons.notifications_off,
                            ),
                            _buildPopupItem(
                              'delete',
                              'Delete Notification',
                              Icons.delete,
                            ),
                            _buildPopupItem('read', 'Mark as Read', Icons.mail),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AqiBottomNavBar(currentIndex: 3),
    );
  }
}

PopupMenuItem<String> _buildPopupItem(
  String value,
  String label,
  IconData icon,
) {
  bool isHovered = false; // ✅ Move here (outside builder)
  return PopupMenuItem<String>(
    value: value,
    padding: EdgeInsets.zero,
    child: StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isHovered
                  ? darkgrey // ✅ Dark Red Hover
                  : white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: black, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
