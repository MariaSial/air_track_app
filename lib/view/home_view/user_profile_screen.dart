// lib/view/home_view/user_profile_screen.dart
import 'package:air_track_app/view/home_view/edit_profile_screen.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:flutter/material.dart';
import 'package:air_track_app/services/auth_storage.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthStorage.getUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  String _u(String key) {
    if (_user == null) return '';
    final val = _user![key];
    if (val == null) return '';
    return val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              const AqiAppBar(title: "User Profile"),

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Column(
                          children: [
                            // Avatar
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: blue,
                                boxShadow: [
                                  BoxShadow(
                                    color: grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(Icons.person, size: 60, color: white),
                            ),

                            const SizedBox(height: 16),

                            // Card with fields
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: white,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    children: [
                                      _buildProfileInfoRow('Name', _u('name')),
                                      _buildProfileInfoRow('CNIC', _u('cnic')),
                                      _buildProfileInfoRow('City', _u('city')),
                                      _buildProfileInfoRow(
                                        'Email',
                                        _u('email'),
                                      ),
                                      _buildProfileInfoRow(
                                        'Phone',
                                        _u('phone'),
                                      ),

                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: BlueButton(
                                text: "Edit Profile",
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const EditProfileScreen(),
                                    ),
                                  );
                                  // reload when returning (edit screen should save to AuthStorage)
                                  await _loadUser();
                                },
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(String label, String value) {
    final displayValue = (value.isEmpty) ? '-' : value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(
              label,
              style: TextStyle(
                color: grey,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(displayValue, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
