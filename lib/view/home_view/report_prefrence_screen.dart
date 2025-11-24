import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class ReportPreferencesScreen extends StatefulWidget {
  const ReportPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<ReportPreferencesScreen> createState() =>
      _ReportPreferencesScreenState();
}

class _ReportPreferencesScreenState extends State<ReportPreferencesScreen> {
  String _frequency = 'Immediately';
  final Map<String, bool> _categories = {
    'Vehicular emissions': true,
    'Industrial Pollution': false,
    'Construction & Road Dust': false,
    'Garbage Burning': true,
    'Household & Commercial Emissions': false,
    'Natural Events': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: "Report Prefrences"),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Frequency',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._buildRadioOptions(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._categories.keys.map(
                            (key) => CheckboxListTile(
                              title: Text(key),
                              value: _categories[key],
                              onChanged: (val) =>
                                  setState(() => _categories[key] = val!),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
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

  List<Widget> _buildRadioOptions() {
    return ['Immediately', 'Hourly', 'Daily'].map((option) {
      return RadioListTile<String>(
        title: Text(option),
        value: option,
        groupValue: _frequency,
        onChanged: (val) => setState(() => _frequency = val!),
        contentPadding: EdgeInsets.zero,
      );
    }).toList();
  }
}
