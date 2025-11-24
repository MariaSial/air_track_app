import 'dart:convert';
import 'package:air_track_app/model/air_quality_model.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class AirQualityService {
  static final String _apiKey = key;
  static const String _geoUrl = 'http://api.openweathermap.org/geo/1.0/direct';

  // ⚠️ IMPORTANT: Update this with your actual API base URL
  // Example: 'https://your-domain.com/api' or 'http://192.168.1.100:3000/api'
  static const String _customApiBaseUrl =
      'https://testproject.famzhost.com/api/v1';

  // Get air quality data based on user's current location
  Future<AirQualityModel?> getAirQualityFromCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      return await getAirQuality(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting air quality from current location: $e');
      return null;
    }
  }

  Future<String?> getLocationName(double lat, double lon) async {
    try {
      final results = await searchLocations('$lat,$lon');
      if (results.isNotEmpty) return results[0]['name'];
      return null;
    } catch (_) {
      return null;
    }
  }

  // Get air quality data for specific coordinates from your custom API (Today/Daily)
  Future<AirQualityModel?> getAirQuality(double lat, double lon) async {
    try {
      print('\n========== DAILY API REQUEST ==========');
      print('Fetching daily AQI for lat: $lat, lon: $lon');

      // Build URL with query parameters matching your API format
      final url = Uri.parse('$_customApiBaseUrl/aqi-reports/fetch').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'period': 'daily',
        },
      );

      print('API URL: $url');

      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        print('Success: ${jsonData['success']}');
        print('Data count: ${jsonData['count']}');
        print('Expected count: 1 (for daily)');

        if (jsonData['count'] != 1) {
          print(
            '⚠️ WARNING: Daily period should return exactly 1 data point, got ${jsonData['count']}',
          );
        }

        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data'].isNotEmpty) {
          // Check if location data matches request
          var firstItem = jsonData['data'][0];
          print('Returned lat: ${firstItem['lat']}, Requested lat: $lat');
          print('Returned lon: ${firstItem['lon']}, Requested lon: $lon');

          double latDiff = ((firstItem['lat'] ?? lat) - lat).abs();
          double lonDiff = ((firstItem['lon'] ?? lon) - lon).abs();

          if (latDiff > 1.0 || lonDiff > 1.0) {
            print('⚠️ WARNING: API returned data for a different location!');
            print('Difference - Lat: $latDiff, Lon: $lonDiff');
          }

          return _convertCustomApiToModel(jsonData, lat, lon);
        } else {
          print('❌ API returned no data or unsuccessful response');
          return null;
        }
      } else {
        print('❌ Failed to load air quality data: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching air quality data: $e');
      return null;
    }
  }

  // Get weekly air quality data from your custom API
  Future<AirQualityModel?> getWeeklyAirQuality(double lat, double lon) async {
    try {
      print('\n========== WEEKLY API REQUEST ==========');
      print('Fetching weekly AQI for lat: $lat, lon: $lon');

      final url = Uri.parse('$_customApiBaseUrl/aqi-reports/fetch').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'period': 'weekly',
        },
      );

      print('API URL: $url');

      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        print('Success: ${jsonData['success']}');
        print('Data count: ${jsonData['count']}');
        print('Expected count: 7 (for weekly)');

        if (jsonData['count'] != 7) {
          print(
            '⚠️ WARNING: Weekly period should return 7 data points (one per day), got ${jsonData['count']}',
          );
          print(
            '❌ Your backend needs to return daily averages for the last 7 days',
          );
        }

        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data'].isNotEmpty) {
          return _convertCustomApiToModel(jsonData, lat, lon);
        }
        return null;
      } else {
        print(
          '❌ Failed to load weekly air quality data: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Error fetching weekly air quality data: $e');
      return null;
    }
  }

  // Get monthly air quality data from your custom API
  Future<AirQualityModel?> getMonthlyAirQuality(double lat, double lon) async {
    try {
      print('\n========== MONTHLY API REQUEST ==========');
      print('Fetching monthly AQI for lat: $lat, lon: $lon');

      final url = Uri.parse('$_customApiBaseUrl/aqi-reports/fetch').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'period': 'monthly',
        },
      );

      print('API URL: $url');

      final response = await http.get(url);
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        print('Success: ${jsonData['success']}');
        print('Data count: ${jsonData['count']}');
        print('Expected count: 30 (for monthly)');

        if (jsonData['count'] != 30) {
          print(
            '⚠️ WARNING: Monthly period should return 30 data points (one per day), got ${jsonData['count']}',
          );
          print(
            '❌ Your backend needs to return daily averages for the last 30 days',
          );
        }

        if (jsonData['success'] == true &&
            jsonData['data'] != null &&
            jsonData['data'].isNotEmpty) {
          return _convertCustomApiToModel(jsonData, lat, lon);
        }
        return null;
      } else {
        print(
          '❌ Failed to load monthly air quality data: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Error fetching monthly air quality data: $e');
      return null;
    }
  }

  // Convert your custom API response to AirQualityModel format
  AirQualityModel _convertCustomApiToModel(
    Map<String, dynamic> jsonData,
    double lat,
    double lon,
  ) {
    List<AirQualityData> dataList = [];

    print('Converting ${jsonData['data'].length} data points');

    for (var item in jsonData['data']) {
      // Your API returns AQI value directly (1-5 scale based on your data)
      int aqiValue = (item['aqi'] as num).toInt();

      // Parse the created_at timestamp
      DateTime timestamp;
      try {
        timestamp = DateTime.parse(item['created_at']);
      } catch (e) {
        print('Error parsing timestamp: $e');
        timestamp = DateTime.now();
      }

      dataList.add(
        AirQualityData(
          main: MainAqi(aqi: aqiValue),
          components: Components(
            co: (item['co'] ?? 0).toDouble(),
            no: (item['no'] ?? 0).toDouble(),
            no2: (item['no2'] ?? 0).toDouble(),
            o3: (item['o3'] ?? 0).toDouble(),
            so2: (item['so2'] ?? 0).toDouble(),
            pm2_5: (item['pm2_5'] ?? 0).toDouble(),
            pm10: (item['pm10'] ?? 0).toDouble(),
            nh3: (item['nh3'] ?? 0).toDouble(),
          ),
          dt: timestamp.millisecondsSinceEpoch ~/ 1000,
        ),
      );
    }

    print('Converted ${dataList.length} data points successfully');

    return AirQualityModel(
      coord: Coord(lat: lat, lon: lon),
      list: dataList,
    );
  }

  // Search for locations - RESTRICTED TO PAKISTAN ONLY
  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      print('Searching for locations: $query');

      // Add Pakistan to the search query to restrict results
      final searchQuery = '$query, Pakistan';
      final url = Uri.parse('$_geoUrl?q=$searchQuery&limit=10&appid=$_apiKey');

      print('Search URL: $url');

      final response = await http.get(url);
      print('Search response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Found ${data.length} locations');

        // Filter to only include locations in Pakistan
        final pakistanLocations = data.where((location) {
          String country = (location['country'] ?? '').toString().toUpperCase();
          return country == 'PK' || country == 'PAKISTAN';
        }).toList();

        print('Filtered to ${pakistanLocations.length} Pakistan locations');

        return pakistanLocations
            .map(
              (location) => {
                'name': location['name'] ?? '',
                'country': 'Pakistan',
                'state': location['state'] ?? '',
                'lat': location['lat'],
                'lon': location['lon'],
              },
            )
            .toList();
      }
      return [];
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  // Get air quality for specific location and time period
  Future<AirQualityModel?> getAirQualityForLocation(
    double lat,
    double lon,
    String timePeriod,
  ) async {
    switch (timePeriod) {
      case 'Weekly':
        return await getWeeklyAirQuality(lat, lon);
      case 'Monthly':
        return await getMonthlyAirQuality(lat, lon);
      default: // Today
        return await getAirQuality(lat, lon);
    }
  }

  // Determine user's current position with proper permission handling
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Get user's current location without fetching air quality data
  Future<Position?> getCurrentLocation() async {
    try {
      return await _determinePosition();
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }
}

class AirQualityApiDebugger {
  // Test if API returns different data for different locations
  static Future<void> testLocationSpecificity() async {
    print('\n========== TESTING LOCATION SPECIFICITY ==========');

    final testLocations = [
      {'name': 'Islamabad', 'lat': 33.6844, 'lon': 73.0479},
      {'name': 'Karachi', 'lat': 24.8607, 'lon': 67.0011},
      {'name': 'Lahore', 'lat': 31.5204, 'lon': 74.3587},
    ];

    for (var location in testLocations) {
      print('\nTesting ${location['name']}:');
      print(
        'URL: https://testproject.famzhost.com/api/v1/aqi-reports/fetch?lat=${location['lat']}&lon=${location['lon']}&period=daily',
      );
      print('Expected: Different AQI values for each city');
      print('Check your API response manually using Postman or browser');
    }
  }

  // Test if API returns correct number of data points
  static Future<void> testPeriodDataPoints() async {
    print('\n========== TESTING PERIOD DATA POINTS ==========');

    final periods = ['daily', 'weekly', 'monthly'];
    final expectedCounts = {'daily': 1, 'weekly': 7, 'monthly': 30};

    const lat = 33.6844;
    const lon = 73.0479;

    for (var period in periods) {
      print('\nTesting $period period:');
      print(
        'URL: https://testproject.famzhost.com/api/v1/aqi-reports/fetch?lat=$lat&lon=$lon&period=$period',
      );
      print('Expected count: ${expectedCounts[period]} data points');
      print('Check your API response - "count" field should match');
    }
  }

  // Print API request details for debugging
  static void logApiRequest(String period, double lat, double lon) {
    print('\n========== API REQUEST DEBUG ==========');
    print('Period: $period');
    print('Latitude: $lat');
    print('Longitude: $lon');
    print(
      'Full URL: https://testproject.famzhost.com/api/v1/aqi-reports/fetch?lat=$lat&lon=$lon&period=$period',
    );
    print(
      'Expected response count: ${period == 'daily'
          ? 1
          : period == 'weekly'
          ? 7
          : 30}',
    );
    print('=====================================\n');
  }
}
