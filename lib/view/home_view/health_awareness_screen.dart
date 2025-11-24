import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class HealthAwarenessScreen extends StatelessWidget {
  const HealthAwarenessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: "Health Awareness"),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildExpandableCard(
                      context,
                      'What is AQI? What are the health effects if AQI is in unhealthy range?',
                      'AQI (Air Quality Index) measures how clean or polluted the air is. It ranges from 0 to 500, where higher values mean more pollution.\n\nPeople with heart or lung diseases, children, and older adults are at greater risk. Common symptoms include coughing, throat irritation, and shortness of breath. Outdoor activities should be reduced or avoided, especially for sensitive groups. Using masks and staying indoors can help reduce exposure.',
                    ),
                    const SizedBox(height: 16),
                    _buildExpandableCard(
                      context,
                      'What are the AQI categories and their health meanings?',
                      'The AQI is usually divided into six color-coded levels:\n\n• 0-50 (Good): Air is clean and healthy.\n• 51-100 (Moderate): Acceptable, but some pollutants may affect sensitive people.\n• 101-150 (Unhealthy for Sensitive Groups): Asthma patients, children, and elders may feel effects.\n• 151-200 (Unhealthy): Everyone may start to feel health symptoms.\n• 201-300 (Very Unhealthy): Serious effects on health; limit outdoor activity.\n• 301-500 (Hazardous): Dangerous for all; emergency conditions declared.',
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

  Widget _buildExpandableCard(
    BuildContext context,
    String question,
    String answer,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
