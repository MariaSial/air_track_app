import 'dart:io';
import 'package:air_track_app/model/air_quality_model.dart';
import 'package:air_track_app/services/air_quality_service.dart';
import 'package:air_track_app/view/aqi_analytics/daily_view.dart';
import 'package:air_track_app/view/aqi_analytics/historical_view.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_bottom_nav_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/loading_state.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/location_helper.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AqiAnalyticsView extends StatefulWidget {
  const AqiAnalyticsView({Key? key}) : super(key: key);

  @override
  State<AqiAnalyticsView> createState() => _AqiAnalyticsViewState();
}

class _AqiAnalyticsViewState extends State<AqiAnalyticsView> {
  final TextEditingController _searchController = TextEditingController();
  final AirQualityService _airQualityService = AirQualityService();

  // State variables
  AirQualityModel? _airQualityData;
  Position? _userPosition;
  bool _isLoading = false;
  String? _errorMessage;
  String _locationName = 'Loading...';
  double? _searchedLat;
  double? _searchedLon;
  bool _isSearchedLocation = false;

  // Time period selection
  String _selectedTimePeriod = 'Today';
  final List<String> _timePeriods = ['Today', 'Weekly', 'Monthly'];
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadAirQuality();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Handle location search and selection
  Future<void> _loadAirQualityForSearchedLocation(
    double lat,
    double lon,
    String locationName,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Fetching data for searched location: $locationName ($lat, $lon)');

      AirQualityModel? data = await _airQualityService.getAirQualityForLocation(
        lat,
        lon,
        _selectedTimePeriod,
      );

      if (data == null) {
        setState(() {
          _errorMessage = 'No air quality data available for this location';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _airQualityData = data;
        _searchedLat = lat;
        _searchedLon = lon;
        _locationName = locationName;
        _isSearchedLocation = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading searched location data: $e');
      setState(() {
        _errorMessage = 'Failed to load air quality data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Load air quality data from user's current location
  Future<void> _loadAirQuality() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // If we have a searched location, use that
      if (_isSearchedLocation && _searchedLat != null && _searchedLon != null) {
        print('Reloading searched location data: $_locationName');

        AirQualityModel? data = await _airQualityService
            .getAirQualityForLocation(
              _searchedLat!,
              _searchedLon!,
              _selectedTimePeriod,
            );

        setState(() {
          _airQualityData = data;
          _isLoading = false;
        });
        return;
      }

      // Get user's current position
      Position? position = await _getPosition();
      if (position == null) {
        setState(() {
          _errorMessage =
              'Unable to get location. Please enable location services.';
          _isLoading = false;
        });
        return;
      }

      print('User position: ${position.latitude}, ${position.longitude}');

      // Get location name
      final locationName = await LocationHelper.getLocationName(
        position.latitude,
        position.longitude,
      );

      print('Location name: $locationName');

      // Fetch air quality data based on selected time period
      AirQualityModel? data = await _fetchDataForTimePeriod(position);

      if (data == null) {
        setState(() {
          _errorMessage = 'No air quality data available for your location';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _airQualityData = data;
        _userPosition = position;
        _locationName = locationName;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in _loadAirQuality: $e');
      setState(() {
        _errorMessage = 'Failed to load air quality data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Get user position
  Future<Position?> _getPosition() async {
    try {
      // For web/desktop: Use IP-based location or default
      if (kIsWeb ||
          Platform.isWindows ||
          Platform.isMacOS ||
          Platform.isLinux) {
        if (kIsWeb) {
          try {
            Position? webPosition = await _airQualityService
                .getCurrentLocation();
            if (webPosition != null) return webPosition;
          } catch (e) {
            print('Web location failed, using default location: $e');
          }
        }

        // Use default location (Islamabad, Pakistan)
        print('Using default location: Islamabad');
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
        // For mobile: Use GPS
        return await _airQualityService.getCurrentLocation();
      }
    } catch (e) {
      print('Error getting position: $e');
      return null;
    }
  }

  // Fetch data based on time period
  Future<AirQualityModel?> _fetchDataForTimePeriod(Position position) async {
    try {
      print(
        'Fetching $_selectedTimePeriod data for position: ${position.latitude}, ${position.longitude}',
      );

      switch (_selectedTimePeriod) {
        case 'Weekly':
          return await _airQualityService.getWeeklyAirQuality(
            position.latitude,
            position.longitude,
          );
        case 'Monthly':
          return await _airQualityService.getMonthlyAirQuality(
            position.latitude,
            position.longitude,
          );
        default: // Today
          return await _airQualityService.getAirQuality(
            position.latitude,
            position.longitude,
          );
      }
    } catch (e) {
      print('Error fetching data for time period: $e');
      return null;
    }
  }

  // Handle time period change
  void _onTimePeriodChanged(String? newValue) {
    if (newValue != null && newValue != _selectedTimePeriod) {
      setState(() {
        _selectedTimePeriod = newValue;
      });
      _loadAirQuality();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: 'AQI Analytics'),
              Expanded(
                child: _isLoading
                    ? LoadingState()
                    : _errorMessage != null
                    ? ErrorStateWidget(
                        errorMessage: _errorMessage!,
                        onRetry: _loadAirQuality,
                      )
                    : _airQualityData == null
                    ? Center(child: Text('No data available'))
                    : _buildContentState(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AqiBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildContentState() {
    if (_selectedTimePeriod == 'Today') {
      return DailyView(
        searchController: _searchController,
        timePeriods: _timePeriods,
        selectedTimePeriod: _selectedTimePeriod,
        onTimePeriodChanged: _onTimePeriodChanged,
        onRefresh: _loadAirQuality,
        locationName: _locationName,
        airQualityData: _airQualityData!,
        airQualityService: _airQualityService,
        onLocationSelected: _loadAirQualityForSearchedLocation,
      );
    } else {
      return HistoricalView(
        searchController: _searchController,
        timePeriods: _timePeriods,
        selectedTimePeriod: _selectedTimePeriod,
        onTimePeriodChanged: _onTimePeriodChanged,
        onRefresh: _loadAirQuality,
        locationName: _locationName,
        airQualityData: _airQualityData!,
        airQualityService: _airQualityService,
        onLocationSelected: _loadAirQualityForSearchedLocation,
      );
    }
  }
}

// Error State Widget
class ErrorStateWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
