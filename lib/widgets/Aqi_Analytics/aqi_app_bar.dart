import 'dart:async';
import 'dart:convert';

import 'package:air_track_app/view/home_view/about_screen.dart';
import 'package:air_track_app/view/home_view/health_awareness_screen.dart';
import 'package:air_track_app/view/home_view/setting_screen.dart';
import 'package:air_track_app/view/home_view/user_profile_screen.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AqiAppBar extends StatelessWidget {
  final String title;

  /// Optional refresh callback. Parent screens should provide a function
  /// that re-runs their API calls (and updates UI).
  final Future<void> Function()? onRefresh;

  const AqiAppBar({super.key, required this.title, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: black,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          /// ---------- Popup Menu Button (More Vert) ----------
          PopupMenuButton<String>(
            // color: white,
            icon: Icon(Icons.more_vert, color: black),
            onSelected: (value) async {
              switch (value) {
                case 'about':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                  break;

                case 'help':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HealthAwarenessScreen(),
                    ),
                  );
                  break;

                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const UserProfileScreen(),
                    ),
                  );
                  break;

                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  break;

                case 'signout':
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) break;

                  // show loading spinner
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  try {
                    const String logoutUrl =
                        'https://testproject.famzhost.com/api/v1/logout';

                    final prefs = await SharedPreferences.getInstance();
                    final token = prefs.getString('auth_token');

                    if (token == null || token.isEmpty) {
                      // close loading
                      if (Navigator.of(context, rootNavigator: true).canPop())
                        Navigator.of(context, rootNavigator: true).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No auth token found. You may already be signed out.',
                          ),
                        ),
                      );
                      // Navigate to signin to be safe
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.signinview,
                        (r) => false,
                      );
                      break;
                    }

                    final response = await http
                        .post(
                          Uri.parse(logoutUrl),
                          headers: {
                            'Content-Type': 'application/json',
                            'Accept':
                                'application/json', // ask server to return JSON not HTML redirect
                            'X-Requested-With':
                                'XMLHttpRequest', // sometimes helps servers return JSON
                            'Authorization': 'Bearer $token',
                          },
                        )
                        .timeout(const Duration(seconds: 20));

                    // close loading dialog
                    if (Navigator.of(context, rootNavigator: true).canPop()) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }

                    // DEBUG: print status + body to console (check device logs)
                    debugPrint('Logout status: ${response.statusCode}');
                    debugPrint('Logout headers: ${response.headers}');
                    debugPrint('Logout body: ${response.body}');

                    if (response.statusCode == 200) {
                      // success: parse message if provided
                      String message = 'Signed out';
                      try {
                        final body = jsonDecode(response.body);
                        if (body is Map && body['message'] != null)
                          message = body['message'].toString();
                      } catch (_) {}

                      // clear tokens / session
                      await prefs.remove('auth_token'); // adjust keys as needed
                      // await prefs.remove('refresh_token');

                      // go to SignIn
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.signinview,
                        (route) => false,
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
                    } else if (response.statusCode >= 300 &&
                        response.statusCode < 400) {
                      // Redirect (302 etc) — show info to help debug
                      final location =
                          response.headers['location'] ?? 'unknown';
                      String bodyPreview = response.body;
                      if (bodyPreview.length > 300)
                        bodyPreview = bodyPreview.substring(0, 300) + '...';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Server redirected ($location). Response: ${response.statusCode}',
                          ),
                        ),
                      );
                      // For debugging, also print body in logs (already printed above).
                      debugPrint(
                        'Redirect location: $location\nbodyPreview: $bodyPreview',
                      );

                      // Likely cause: invalid/missing token or server returning HTML. See notes below.
                    } else {
                      // Non-200 error — show server message if present
                      String err = 'Sign out failed (${response.statusCode})';
                      try {
                        final body = jsonDecode(response.body);
                        if (body is Map && body['message'] != null)
                          err = body['message'].toString();
                      } catch (_) {}
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(err)));
                    }
                  } on TimeoutException catch (_) {
                    if (Navigator.of(context, rootNavigator: true).canPop())
                      Navigator.of(context, rootNavigator: true).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Request timed out. Please check your connection.',
                        ),
                      ),
                    );
                  } catch (e) {
                    if (Navigator.of(context, rootNavigator: true).canPop())
                      Navigator.of(context, rootNavigator: true).pop();

                    // Distinguish common mobile issues
                    String userMsg = 'Sign out failed: $e';
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(userMsg)));
                    debugPrint('Sign out exception: $e');
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 10),
                    Text('About'),
                  ],
                ),
              ),

              const PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    Icon(Icons.help_outline),
                    SizedBox(width: 10),
                    Text('Help'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 10),
                    Text('User Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 10),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 10),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
