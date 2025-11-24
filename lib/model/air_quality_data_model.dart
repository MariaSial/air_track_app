// API DATA MODELS

// Represents a single point of AQI data
import 'dart:ui';

import 'package:air_track_app/widgets/app_colors.dart';

class AirQualityDataModel {
  final int aqi;
  final String status;
  final Color statusColor;
  final String location;
  final double latitude;
  final double longitude;
  final Map<String, int> pollutants;

  AirQualityDataModel({
    required this.aqi,
    required this.status,
    required this.statusColor,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.pollutants,
  });
}

// Represents a day in the forecast
class ForecastDay {
  final String day;
  final String date;
  final int minAqi;
  final int maxAqi;

  ForecastDay({
    required this.day,
    required this.date,
    required this.minAqi,
    required this.maxAqi,
  });
}

// MOCK API FUNCTIONS

// Mock function to simulate fetching real-time air quality data
Future<AirQualityDataModel> fetchAirQualityData() async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 1200));

  return AirQualityDataModel(
    aqi: 165,
    status: 'Unhealthy',
    statusColor: kUnhealthyColor,
    location: 'London, UK',
    latitude: 51.5074,
    longitude: 0.1278,
    pollutants: {
      'PM2.5': 65,
      'PM10': 120,
      'O3': 80,
      'NO2': 50,
      'SO2': 10,
      'CO': 5,
    },
  );
}

// Mock function to simulate fetching forecast data
Future<List<ForecastDay>> fetchForecast() async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 800));

  return [
    ForecastDay(day: 'Today', date: '21/09', minAqi: 150, maxAqi: 170),
    ForecastDay(day: 'Tomorrow', date: '22/09', minAqi: 100, maxAqi: 120),
    ForecastDay(day: 'Wed', date: '23/09', minAqi: 50, maxAqi: 70),
    ForecastDay(day: 'Thu', date: '24/09', minAqi: 30, maxAqi: 45),
  ];
}
