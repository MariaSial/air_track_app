import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:flutter/material.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  bool _gpsEnabled = true;
  bool _useCurrentLocation = true;
  String _selectedCity = 'Peshawar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: "Location Settings"),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSwitchCard(
                      'Turn on GPS',
                      _gpsEnabled,
                      (val) => setState(() => _gpsEnabled = val),
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchCard(
                      'Use My Current Location',
                      _useCurrentLocation,
                      (val) => setState(() => _useCurrentLocation = val),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select City Manually',
                            style: TextStyle(fontSize: 14, color: grey),
                          ),
                          DropdownButton<String>(
                            value: _selectedCity,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: cities.map((city) {
                              return DropdownMenuItem(
                                value: city,
                                child: Text(city),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCity = val!),
                          ),
                        ],
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

  Widget _buildSwitchCard(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Switch(value: value, onChanged: onChanged, activeColor: blue),
        ],
      ),
    );
  }
}
