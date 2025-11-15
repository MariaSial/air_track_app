import 'package:air_track_app/view/notifications/notification_detail_view.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_bottom_nav_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:air_track_app/providers/notification_provider.dart';

class NotificationView extends ConsumerStatefulWidget {
  const NotificationView({super.key});

  @override
  ConsumerState<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends ConsumerState<NotificationView> {
  @override
  void initState() {
    super.initState();
    // initialize provider data after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider).init();
    });
  }

  Future<void> _refresh() async {
    await ref.read(notificationProvider).refresh();
  }

  void _onMenuSelected(String value, int index) async {
    final provider = ref.read(notificationProvider);
    final notif = provider.notifications[index];

    switch (value) {
      case 'view':
        if (!notif['isRead']) {
          await provider.markAsRead(notif['id'], index: index);
        }
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailView(notification: notif),
          ),
        );
        break;
      case 'mute':
        provider.muteNotificationAt(index);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notification muted')));
        break;
      case 'delete':
        final success = await provider.deleteNotification(
          notif['id'],
          index: index,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Notification deleted' : 'Failed to delete',
            ),
          ),
        );
        break;
      case 'read':
        final success = await provider.markAsRead(notif['id'], index: index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Marked as read' : 'Failed to mark as read',
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(notificationProvider);

    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: "Notifications"),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: red),
                          ),
                        ),
                      )
                    : provider.notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: black,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: provider.notifications.length,
                          itemBuilder: (context, index) {
                            final notif = provider.notifications[index];
                            return Card(
                              margin: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: notif['image'] != null
                                      ? Image.network(
                                          notif['image'],
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  Image.asset(
                                                    reportcard,
                                                    width: 60,
                                                    height: 60,
                                                  ),
                                        )
                                      : Image.asset(
                                          reportcard,
                                          width: 60,
                                          height: 60,
                                        ),
                                ),
                                title: Text(
                                  notif['title'] ?? 'Notification',
                                  style: TextStyle(
                                    fontWeight: notif['isRead']
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(notif['time'] ?? ''),
                                trailing: PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert, color: black),
                                  color: white,
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: lightgrey),
                                  ),
                                  onSelected: (value) =>
                                      _onMenuSelected(value, index),
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
                                    if (!notif['isRead'])
                                      _buildPopupItem(
                                        'read',
                                        'Mark as Read',
                                        Icons.mark_email_read,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AqiBottomNavBar(currentIndex: 3),
    );
  }
}

PopupMenuItem<String> _buildPopupItem(
  String value,
  String label,
  IconData icon,
) {
  bool isHovered = false;
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
              color: isHovered ? darkgrey : white,
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
