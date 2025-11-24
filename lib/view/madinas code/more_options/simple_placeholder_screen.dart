import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';

// Placeholder for all detailed screens requested by the user
class SimplePlaceholderScreen extends StatelessWidget {
  final String title;
  const SimplePlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBlue,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, color: kAccentGreen, size: 60),
              const SizedBox(height: 20),
              Text(
                'This is the $title Screen',
                textAlign: TextAlign.center,
                style: kTextTheme.headlineMedium?.copyWith(color: kAccentGreen),
              ),
              const SizedBox(height: 10),
              Text(
                'Full implementation of interactive elements like forms and toggles would go here, following the Figma design.',
                textAlign: TextAlign.center,
                style: kTextTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Navigated from MoreOptionsScreen -> View Profile
class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a full app, this screen would show user details and have an 'Edit Profile' button.
    return Scaffold(
      backgroundColor: kPrimaryBlue,
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: kAccentGreen,
              child: Icon(Icons.person, size: 80, color: kPrimaryBlue),
            ),
            const SizedBox(height: 20),
            Text('Jane Doe', style: kTextTheme.headlineLarge),
            Text('Location: London, UK', style: kTextTheme.titleLarge),
            Text('Email: janedoe@example.com', style: kTextTheme.bodyMedium),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.edit, color: kPrimaryBlue),
              label: Text(
                'Edit Profile Screen',
                style: kTextTheme.labelLarge?.copyWith(color: kPrimaryBlue),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: kAccentGreen),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholderScreen(title: 'Edit Profile Screen');
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholderScreen(title: 'Setting');
  }
}

class LocationSettingScreen extends StatelessWidget {
  const LocationSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholderScreen(title: 'Location Setting');
  }
}

class ReportPreferencesScreen extends StatelessWidget {
  const ReportPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholderScreen(title: 'Report Preferences');
  }
}

class PrivacyPermissionsScreen extends StatelessWidget {
  const PrivacyPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholderScreen(title: 'Privacy and Permissions');
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholderScreen(title: 'Help');
  }
}

class ReadMoreScreen extends StatelessWidget {
  const ReadMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholderScreen(title: 'Read More');
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePlaceholderScreen(title: 'About');
  }
}
