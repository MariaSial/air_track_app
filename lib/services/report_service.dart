// lib/services/report_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:air_track_app/services/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// ReportService - submit reports as multipart/form-data and fetch media bytes
class ReportService {
  static const String baseUrl = 'https://testproject.famzhost.com';
  static const String submitUrl = '$baseUrl/add-reports';

  /// Submit report as multipart/form-data (NOT JSON)
  static Future<Map<String, dynamic>> submitReport({
    required String title,
    required String description,
    required String location,
    required String pollutionType,
    File? photo,
    double? lat,
    double? lng,
  }) async {
    print('📤 ═══════════════════════════════════════');
    print('📤 Submitting Report as MULTIPART/FORM-DATA');
    print('📤 ═══════════════════════════════════════');

    final token = await AuthStorage.getToken();
    if (token == null) {
      print('❌ No auth token found');
      throw HttpException('User not authenticated');
    }

    print('✓ Auth token: ${token.substring(0, 20)}...');

    final uri = Uri.parse(submitUrl);
    print('✓ Endpoint: $uri');

    // Create multipart request
    final request = http.MultipartRequest('POST', uri);

    // Set headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    // NOTE: Do NOT set Content-Type manually, http package handles it for multipart

    print('✓ Headers set');

    // Add form fields (as strings, NOT JSON)
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['location'] = location;
    request.fields['pollution_type'] = pollutionType;

    print('✓ Form fields:');
    print('  - title: $title');
    print('  - description: ${description.length} chars');
    print('  - location: $location');
    print('  - pollution_type: $pollutionType');

    if (lat != null) {
      request.fields['lat'] = lat.toString();
      print('  - lat: $lat');
    }
    if (lng != null) {
      request.fields['long'] = lng.toString();
      print('  - long: $lng');
    }

    // Add image file if provided
    if (photo != null) {
      // Verify file exists
      if (!await photo.exists()) {
        print('  ❌ Image file does not exist at path: ${photo.path}');
        throw HttpException('Image file not found');
      }

      final filename = path.basename(photo.path);
      final fileSize = await photo.length();

      print('✓ Adding image file:');
      print('  - filename: $filename');
      print('  - size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      print('  - path: ${photo.path}');
      print('  - exists: ${await photo.exists()}');

      try {
        final multipartFile = await http.MultipartFile.fromPath(
          'photo', // Reverted field name
          photo.path,
          filename: filename,
        );

        request.files.add(multipartFile);
        print('  ✅ Image file added successfully');
        print('  - Field name: photo');
        print('  - Content-Type: ${multipartFile.contentType}');
        print('  - Length: ${multipartFile.length} bytes');
        print('  - Total files in request: ${request.files.length}');
      } catch (e) {
        print('  ❌ Failed to add image: $e');
        throw HttpException('Failed to attach image: $e');
      }
    } else {
      print('ℹ️  No image provided');
    }

    print('📤 Sending request...');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 ═══════════════════════════════════════');
      print('📥 Response Received');
      print('📥 ═══════════════════════════════════════');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body length: ${response.body.length}');
      print('Body: ${response.body}');
      print('═══════════════════════════════════════');

      final bodyTrim = response.body.trim();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ Report submitted successfully!');

        if (bodyTrim.isEmpty) {
          return {'message': 'Report submitted successfully'};
        }

        try {
          final decoded = json.decode(bodyTrim);

          if (decoded is Map) {
            print('✓ Response is a Map');
            print('✓ Keys: ${decoded.keys.toList()}');

            // Check if media was attached
            if (decoded['media'] != null) {
              print('✓ Media attached in response: ${decoded['media']}');
            }
            if (decoded['media_url'] != null) {
              print('✓ Media URL: ${decoded['media_url']}');
            }

            return Map<String, dynamic>.from(decoded);
          }

          return {'message': 'Report submitted successfully', 'data': decoded};
        } catch (e) {
          print('⚠️  Response is not JSON: $e');
          return {
            'message': bodyTrim.isNotEmpty
                ? bodyTrim
                : 'Report submitted successfully',
          };
        }
      }

      // Handle error responses
      print('❌ Request failed with status: ${response.statusCode}');
      String errorMsg = 'Request failed: ${response.statusCode}';

      try {
        if (bodyTrim.isNotEmpty) {
          final decoded = json.decode(bodyTrim);

          if (decoded is Map) {
            if (decoded['message'] != null) {
              errorMsg = decoded['message'].toString();
            } else if (decoded['error'] != null) {
              errorMsg = decoded['error'].toString();
            } else if (decoded['errors'] != null) {
              // Handle Laravel validation errors
              final errors = decoded['errors'];
              if (errors is Map) {
                final allErrors = <String>[];
                errors.forEach((key, value) {
                  if (value is List) {
                    allErrors.addAll(value.map((e) => e.toString()));
                  } else {
                    allErrors.add(value.toString());
                  }
                });
                errorMsg = allErrors.join(', ');
              } else {
                errorMsg = errors.toString();
              }
            }
          }
        }
      } catch (e) {
        print('⚠️  Could not parse error response: $e');
      }

      print('Error message: $errorMsg');
      throw HttpException(errorMsg);
    } catch (e) {
      print('❌ Exception during request: $e');
      rethrow;
    }
  }

  /// Try to fetch media bytes for a report
  static Future<Uint8List> getReportMediaBytes({
    int? reportId,
    String? mediaUrl,
    String? filePath,
    String? overrideHost,
  }) async {
    print('🖼️  Fetching media bytes...');
    print('  reportId: $reportId');
    print('  mediaUrl: $mediaUrl');
    print('  overrideHost: $overrideHost');

    final token = await AuthStorage.getToken();
    if (token == null) throw HttpException('User not authenticated');

    // Helper to do authenticated GET and return bytes if OK
    Future<Uint8List?> tryGetBytes(Uri uri) async {
      print('  Trying: $uri');
      try {
        final res = await http.get(
          uri,
          headers: {
            'Accept': 'application/octet-stream',
            'Authorization': 'Bearer $token',
          },
        );
        print('    Status: ${res.statusCode}');
        if (res.statusCode >= 200 &&
            res.statusCode < 300 &&
            res.bodyBytes.isNotEmpty) {
          print('    ✅ Got ${res.bodyBytes.length} bytes');
          return res.bodyBytes;
        }
      } catch (e) {
        print('    ❌ Error: $e');
      }
      return null;
    }

    // Rewrite host if override provided
    String? rewrite(String? raw) {
      if (raw == null) return null;
      if (overrideHost == null) return raw;
      try {
        final u = Uri.parse(raw);
        final scheme = (u.scheme.isEmpty ? 'http' : u.scheme);
        return '$scheme://$overrideHost${u.path}${u.hasQuery ? '?${u.query}' : ''}';
      } catch (_) {
        return raw.replaceAll('localhost', overrideHost);
      }
    }

    // 1) Try mediaUrl if provided
    if (mediaUrl != null && mediaUrl.trim().isNotEmpty) {
      final maybe = rewrite(mediaUrl);
      try {
        final uri = Uri.parse(maybe!);
        final bytes = await tryGetBytes(uri);
        if (bytes != null) return bytes;
      } catch (_) {}
    }

    // 2) Try filePath with common prefixes
    if (filePath != null && filePath.trim().isNotEmpty) {
      final prefixes = ['$baseUrl/storage/', '$baseUrl/media/'];
      for (final p in prefixes) {
        final candidate = rewrite(p + filePath) ?? (p + filePath);
        try {
          final uri = Uri.parse(candidate);
          final bytes = await tryGetBytes(uri);
          if (bytes != null) return bytes;
        } catch (_) {}
      }
    }

    // 3) Try reportId media endpoints
    if (reportId != null) {
      final candidates = [
        '$baseUrl/api/v1/reports/$reportId/media',
        '$baseUrl/storage/reports/$reportId',
        '$baseUrl/media/$reportId',
      ];
      for (final url in candidates) {
        final candidate = rewrite(url) ?? url;
        try {
          final uri = Uri.parse(candidate);
          final bytes = await tryGetBytes(uri);
          if (bytes != null) return bytes;
        } catch (_) {}
      }
    }

    // 4) Last resort: fetch report and check for media URLs
    if (reportId != null) {
      try {
        final info = await getReportById(reportId);

        // Check media array
        if (info['media'] is List && (info['media'] as List).isNotEmpty) {
          final m0 = (info['media'] as List).first;
          if (m0 is Map && m0['original_url'] is String) {
            final candidate =
                rewrite(m0['original_url'] as String) ??
                (m0['original_url'] as String);
            final uri = Uri.parse(candidate);
            final bytes = await tryGetBytes(uri);
            if (bytes != null) return bytes;
          }
        }
      } catch (e) {
        print('  ❌ Failed to fetch report details: $e');
      }
    }

    throw HttpException('Failed to fetch media bytes from server');
  }

  /// Fetch full report info by id
  static Future<Map<String, dynamic>> getReportById(int id) async {
    final token = await AuthStorage.getToken();
    if (token == null) throw HttpException('User not authenticated');

    final candidates = [
      '$baseUrl/api/v1/reports/$id',
      '$baseUrl/api/v1/my-reports/$id',
      '$baseUrl/api/v1/report/$id',
    ];

    for (final url in candidates) {
      try {
        final res = await http.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (res.statusCode >= 200 &&
            res.statusCode < 300 &&
            res.body.trim().isNotEmpty) {
          final decoded = json.decode(res.body.trim());
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
          if (decoded is Map && decoded['data'] is Map) {
            return Map<String, dynamic>.from(decoded['data']);
          }
        }
      } catch (_) {}
    }

    throw HttpException('Failed to fetch report details');
  }
}
