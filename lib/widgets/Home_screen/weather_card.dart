// weather_card.dart
import 'package:air_track_app/widgets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:air_track_app/services/weather_service.dart';
import 'package:air_track_app/widgets/app_colors.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  Map<String, dynamic>? _weatherData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final location = await WeatherService().getCurrentLocation();
      print('Current location: ${location.latitude}, ${location.longitude}');

      final data = await WeatherService().getWeatherForLocation(
        location.latitude,
        location.longitude,
      );

      print('Weather data: $data');

      setState(() {
        _weatherData = data;
        _loading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching weather: $e');
      print(stackTrace);

      // Optional: fallback to a fixed location (Karachi) if GPS fails
      try {
        final fallbackData = await WeatherService().getWeatherForLocation(
          24.8607,
          67.0011,
        );
        setState(() {
          _weatherData = fallbackData;
          _loading = false;
        });
      } catch (_) {
        setState(() {
          _weatherData = null;
          _loading = false;
        });
      }
    }
  }

  Widget _buildWeatherMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 18),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        width: MediaQuery.sizeOf(context).width * 0.95,
        height: MediaQuery.sizeOf(context).height * 0.4,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_weatherData == null) {
      return Container(
        width: MediaQuery.sizeOf(context).width * 0.95,
        height: MediaQuery.sizeOf(context).height * 0.4,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Weather data not available')),
      );
    }

    return Container(
      width: MediaQuery.sizeOf(context).width * 0.95,
      // height: MediaQuery.sizeOf(context).height * 0.4,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                _weatherData!['date'],
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Image.asset(sun, scale: 1.6),
              const SizedBox(width: 20),
              Text(
                '${_weatherData!['temperature']}°',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(Icons.air, color: Colors.grey[400], size: 40),
            ],
          ),
          const SizedBox(height: 20),
          // Text(
          //   _weatherData!['locationName'],
          //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          // ),
          Text(
            'Weather ${_weatherData!['date']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherMetric(
                Icons.water_drop_outlined,
                '${_weatherData!['humidity']}%',
              ),
              _buildWeatherMetric(
                Icons.arrow_downward,
                '${_weatherData!['rain']}%',
              ),
              _buildWeatherMetric(
                Icons.air,
                '${_weatherData!['windSpeed']} km/h',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
