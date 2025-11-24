// full SettingsScreen (ready to paste)
import 'package:air_track_app/main.dart';
import 'package:air_track_app/view/home_view/location_setting_screen.dart';
import 'package:air_track_app/view/home_view/privacy_screen.dart';
import 'package:air_track_app/view/home_view/report_prefrence_screen.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final selectedLocale = ref.watch(localeProvider);

    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              const AqiAppBar(title: "Settings"),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSettingCard(
                      context,
                      'location_settings'.tr(),
                      'location_subtitle'.tr(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LocationSettingsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildThemeCard(context, ref, isDarkMode),
                    const SizedBox(height: 16),
                    _buildLanguageCard(context, ref, selectedLocale),
                    const SizedBox(height: 16),
                    _buildSettingCard(
                      context,
                      'report_preferences'.tr(),
                      'report_subtitle'.tr(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportPreferencesScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingCard(
                      context,
                      'privacy_permissions'.tr(),
                      'privacy_subtitle'.tr(),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 13, color: grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, WidgetRef ref, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Make the text area flexible so it doesn't overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'theme'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'switch_theme'.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // The switch + icons row
          Row(
            mainAxisSize:
                MainAxisSize.min, // important: only take the space it needs
            children: [
              Icon(
                Icons.wb_sunny,
                color: isDarkMode ? Colors.grey : Colors.blue,
              ),
              Switch(
                value: isDarkMode,
                onChanged: (val) {
                  ref.read(themeProvider.notifier).state = val;
                },
              ),
              Icon(
                Icons.nightlight_round,
                color: isDarkMode ? Colors.blue : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    WidgetRef ref,
    Locale selectedLocale,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'language'.tr(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'select_language'.tr(),
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<Locale>(
              value: selectedLocale,
              underline: const SizedBox(),
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('ur'), child: Text('اردو')),
              ],
              onChanged: (Locale? val) async {
                if (val != null) {
                  // Update EasyLocalization AND Riverpod so .tr() and direction both update correctly
                  await context.setLocale(val);
                  ref.read(localeProvider.notifier).state = val;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
