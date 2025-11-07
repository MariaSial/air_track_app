// location_helper

import 'package:geocoding/geocoding.dart';

class LocationHelper {
  // Get location name from coordinates using reverse geocoding
  static Future<String> getLocationName(
    double latitude,
    double longitude,
  ) async {
    try {
      // Add a small delay to ensure geocoding service is ready
      await Future.delayed(Duration(milliseconds: 500));

      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude).timeout(
            Duration(seconds: 5),
            onTimeout: () {
              print('Geocoding timeout');
              return [];
            },
          );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        print('Placemark details:');
        print('Locality: ${place.locality}');
        print('SubLocality: ${place.subLocality}');
        print('SubAdministrativeArea: ${place.subAdministrativeArea}');
        print('AdministrativeArea: ${place.administrativeArea}');
        print('Country: ${place.country}');

        // Build location name from available data - prioritize city/locality
        if (place.locality != null && place.locality!.isNotEmpty) {
          return place.locality!;
        } else if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          return place.subLocality!;
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          return place.subAdministrativeArea!;
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          return place.administrativeArea!;
        } else if (place.country != null && place.country!.isNotEmpty) {
          return place.country!;
        }
      }

      print('No placemark data found');
      return 'Location ${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    } catch (e) {
      print('Error getting location name: $e');
      return 'Your Location';
    }
  }
}

// File: lib/utils/date_formatter.dart

class DateFormatter {
  // Format date time for "last updated" display
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // Format date for historical view
  static String formatHistoricalDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // Show day of week
      List<String> days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
