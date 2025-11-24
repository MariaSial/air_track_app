import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: "About"),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"Air Track KP" helps you know how clean or polluted the air around you is. It shows real-time Air Quality Index (AQI) so you can stay safe and protect your health.',
                        style: TextStyle(fontSize: 14, height: 1.6),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'You can report pollution problems like smoke, garbage burning, or factory emissions to help make your city cleaner.',
                        style: TextStyle(fontSize: 14, height: 1.6),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Our goal is to keep you informed, spread awareness, and encourage everyone to breathe cleaner, fresher air together.',
                        style: TextStyle(fontSize: 14, height: 1.6),
                      ),
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
}
