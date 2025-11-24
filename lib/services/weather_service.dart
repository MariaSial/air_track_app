// weather_service.dart
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = '16168dba406c9784d20e2a7eca249fa1';
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  // Get current GPS location
  Future<Position> getCurrentLocation() async {
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
      throw Exception(
        'Location permissions are permanently denied, cannot request.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Fetch weather data for given latitude & longitude
  Future<Map<String, dynamic>> getWeatherForLocation(
    double lat,
    double lon,
  ) async {
    final url = Uri.parse(
      '$_baseUrl?lat=$lat&lon=$lon&units=metric&appid=$_apiKey',
    );
    print('Requesting weather API: $url');

    final response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather data');
    }

    final data = json.decode(response.body);

    return {
      'icon': _mapWeatherIcon(data['weather'][0]['icon']),
      'temperature': data['main']['temp'].toInt(),
      'locationName': data['name'],
      'date': DateTime.now().toString().split(' ')[0],
      'humidity': data['main']['humidity'],
      'rain': data['rain']?['1h'] ?? 0,
      'windSpeed': (data['wind']['speed'] * 3.6).toInt(), // m/s → km/h
    };
  }

  // Convert OpenWeatherMap icon code to local asset path
  String _mapWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
        return 'assets/weather/sunny.png';
      case '01n':
        return 'assets/weather/clear_night.png';
      case '02d':
      case '02n':
        return 'assets/weather/partly_cloudy.png';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return 'assets/weather/cloudy.png';
      case '09d':
      case '09n':
        return 'assets/weather/rain.png';
      case '10d':
      case '10n':
        return 'assets/weather/rain.png';
      case '11d':
      case '11n':
        return 'assets/weather/thunderstorm.png';
      case '13d':
      case '13n':
        return 'assets/weather/snow.png';
      case '50d':
      case '50n':
        return 'assets/weather/mist.png';
      default:
        return 'assets/weather/sunny.png';
    }
  }
}
