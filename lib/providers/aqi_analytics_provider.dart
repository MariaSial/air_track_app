// lib/providers/aqi_analytics_provider.dart
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';

import 'package:air_track_app/services/air_quality_service.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/location_helper.dart';
import 'package:air_track_app/model/air_quality_model.dart';

/// Provide AirQualityService instance
final airQualityServiceProvider = Provider<AirQualityService>((ref) {
  return AirQualityService();
});

/// Controller using ChangeNotifier
class AqiAnalyticsController extends ChangeNotifier {
  final Ref ref;

  AqiAnalyticsController(this.ref);

  AirQualityModel? airQualityData;
  Position? userPosition;
  bool isLoading = false;
  String? errorMessage;
  String locationName = 'Loading...';

  double? searchedLat;
  double? searchedLon;
  bool isSearchedLocation = false;

  String selectedTimePeriod = 'Today';
  final List<String> timePeriods = ['Today', 'Weekly', 'Monthly'];

  AirQualityService get _service => ref.read(airQualityServiceProvider);

  Future<void> init() async {
    await loadAirQuality();
  }

  Future<void> loadAirQuality() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (isSearchedLocation && searchedLat != null && searchedLon != null) {
        final data = await _service.getAirQualityForLocation(
          searchedLat!,
          searchedLon!,
          selectedTimePeriod,
        );

        if (data == null) {
          errorMessage = 'No air quality data available for this location';
          isLoading = false;
          notifyListeners();
          return;
        }

        airQualityData = data;
        isLoading = false;
        notifyListeners();
        return;
      }

      final position = await _getPosition();
      if (position == null) {
        errorMessage =
            'Unable to get location. Please enable location services.';
        isLoading = false;
        notifyListeners();
        return;
      }

      userPosition = position;

      final locName = await LocationHelper.getLocationName(
        position.latitude,
        position.longitude,
      );
      locationName = locName ?? 'Unknown';

      final data = await _fetchDataForTimePeriod(position);

      if (data == null) {
        errorMessage = 'No air quality data available for your location';
        isLoading = false;
        notifyListeners();
        return;
      }

      airQualityData = data;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load air quality data: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setTimePeriod(String newPeriod) async {
    if (newPeriod == selectedTimePeriod) return;
    selectedTimePeriod = newPeriod;
    notifyListeners();
    await loadAirQuality();
  }

  Future<void> refresh() async => loadAirQuality();

  Future<void> loadAirQualityForSearchedLocation(
    double lat,
    double lon,
    String locationName,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getAirQualityForLocation(
        lat,
        lon,
        selectedTimePeriod,
      );

      if (data == null) {
        errorMessage = 'No air quality data available for this location';
        isLoading = false;
        notifyListeners();
        return;
      }

      airQualityData = data;
      searchedLat = lat;
      searchedLon = lon;
      this.locationName = locationName;
      isSearchedLocation = true;

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load air quality data: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Position?> _getPosition() async {
    try {
      if (kIsWeb ||
          Platform.isWindows ||
          Platform.isMacOS ||
          Platform.isLinux) {
        if (kIsWeb) {
          try {
            final pos = await _service.getCurrentLocation();
            if (pos != null) return pos;
          } catch (_) {}
        }

        return Position(
          latitude: 33.6844,
          longitude: 73.0479,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        return await _service.getCurrentLocation();
      }
    } catch (_) {
      return null;
    }
  }

  Future<AirQualityModel?> _fetchDataForTimePeriod(Position pos) async {
    switch (selectedTimePeriod) {
      case 'Weekly':
        return await _service.getWeeklyAirQuality(pos.latitude, pos.longitude);
      case 'Monthly':
        return await _service.getMonthlyAirQuality(pos.latitude, pos.longitude);
      default:
        return await _service.getAirQuality(pos.latitude, pos.longitude);
    }
  }
}

final aqiAnalyticsProvider = ChangeNotifierProvider<AqiAnalyticsController>((
  ref,
) {
  return AqiAnalyticsController(ref);
});
