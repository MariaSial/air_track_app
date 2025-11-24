// lib/services/report_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:air_track_app/services/auth_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// ReportService - submit reports as multipart/form-data and fetch media bytes
class ReportService {
  // Public host (what the device can reach). Use your real domain here.
  static const String host = 'testproject.famzhost.com';
  static const String scheme = 'https'; // keep as 'https' if your site uses TLS
  static String get baseHost => '$scheme://$host';
  static const String apiPrefix = '/api/v1';
  static String get apiBase => '$baseHost$apiPrefix';

  // Submit candidates - keep the ones likely to exist (you mentioned my-reports / all-reports)
  static final List<String> _submitCandidates = [
    '$apiBase/add-reports',
    '$apiBase/add-report',
    '$apiBase/my-reports',
    '$apiBase/all-reports',
    '$apiBase/reports',
  ];

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

    print('✓ Auth token available');

    Future<http.Response> _sendTo(Uri uri, String fileFieldName) async {
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      // Attach fields
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['location'] = location;
      request.fields['pollution_type'] = pollutionType;
      if (lat != null) request.fields['lat'] = lat.toString();
      if (lng != null) request.fields['long'] = lng.toString();

      // Attach photo if provided
      if (photo != null) {
        if (!await photo.exists()) {
          throw HttpException('Image file not found at ${photo.path}');
        }
        final filename = path.basename(photo.path);
        final multipartFile = await http.MultipartFile.fromPath(
          fileFieldName,
          photo.path,
          filename: filename,
        );
        request.files.add(multipartFile);
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return response;
    }

    final fileFieldCandidates = ['photo', 'image', 'file'];

    for (final endpoint in _submitCandidates) {
      for (final fileField in fileFieldCandidates) {
        try {
          final uri = Uri.parse(endpoint);
          print('📤 Attempting POST $uri (file field: $fileField)');
          final response = await _sendTo(uri, fileField);

          print('📥 Response from $uri');
          print('Status: ${response.statusCode}');
          print('Body length: ${response.body.length}');
          print('Body: ${response.body}');

          final bodyTrim = response.body.trim();

          if (response.statusCode >= 200 && response.statusCode < 300) {
            if (bodyTrim.isEmpty) {
              return {'message': 'Report submitted successfully'};
            }
            try {
              final decoded = json.decode(bodyTrim);
              if (decoded is Map) return Map<String, dynamic>.from(decoded);
              return {
                'message': 'Report submitted successfully',
                'data': decoded,
              };
            } catch (_) {
              return {'message': bodyTrim};
            }
          }

          if (response.statusCode == 404) {
            print(
              '❌ 404 from $uri (file field: $fileField). Trying next candidate...',
            );
            continue;
          }

          // Other non-success statuses -> parse message and throw
          String errorMsg = 'Request failed: ${response.statusCode}';
          if (bodyTrim.isNotEmpty) {
            try {
              final decoded = json.decode(bodyTrim);
              if (decoded is Map) {
                if (decoded['message'] != null)
                  errorMsg = decoded['message'].toString();
                else if (decoded['error'] != null)
                  errorMsg = decoded['error'].toString();
                else if (decoded['errors'] != null) {
                  final errors = decoded['errors'];
                  if (errors is Map) {
                    final allErrors = <String>[];
                    errors.forEach((k, v) {
                      if (v is List)
                        allErrors.addAll(v.map((e) => e.toString()));
                      else
                        allErrors.add(v.toString());
                    });
                    errorMsg = allErrors.join(', ');
                  } else {
                    errorMsg = errors.toString();
                  }
                }
              } else {
                errorMsg = bodyTrim;
              }
            } catch (_) {
              errorMsg = bodyTrim;
            }
          }
          throw HttpException(errorMsg);
        } catch (e) {
          print('⚠️  Attempt to $endpoint (field $fileField) failed: $e');
          // continue trying other candidates
        }
      }
    }

    throw HttpException(
      'Failed to submit report: no valid endpoint responded.',
    );
  }

  /// Replace localhost/127.0.0.1 in URLs with the real host so mobile devices can reach it.
  static String rewriteLocalhost(String url) {
    if (url == null || url.isEmpty) return url;
    try {
      final u = Uri.parse(url);
      final hostLower = u.host.toLowerCase();
      if (hostLower == 'localhost' ||
          hostLower == '127.0.0.1' ||
          hostLower == '::1') {
        final usedScheme = u.scheme.isNotEmpty ? u.scheme : scheme;
        final pathAndQuery = '${u.path}${u.hasQuery ? '?${u.query}' : ''}';
        return '$usedScheme://$host$pathAndQuery';
      }
    } catch (_) {
      // fallback simple replace
      return url.replaceAll('localhost', host).replaceAll('127.0.0.1', host);
    }
    return url;
  }

  /// Try to fetch media bytes for a report
  static Future<Uint8List> getReportMediaBytes({
    int? reportId,
    String? mediaUrl,
    String? filePath,
    String? overrideHost, // optional: if provided, used in place of `host`
  }) async {
    print('🖼️  Fetching media bytes...');
    print('  reportId: $reportId');
    print('  mediaUrl: $mediaUrl');
    print('  overrideHost: $overrideHost');

    final token = await AuthStorage.getToken();
    if (token == null) throw HttpException('User not authenticated');

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
        } else {
          print('    ✖️ Did not get bytes (status ${res.statusCode})');
        }
      } catch (e) {
        print('    ❌ Error: $e');
      }
      return null;
    }

    String rewrite(String? raw) {
      if (raw == null) return '';
      // If overrideHost is provided, replace host portion with it; otherwise rewrite localhost->host
      if (overrideHost != null && overrideHost.isNotEmpty) {
        try {
          final u = Uri.parse(raw);
          final schemeUsed = u.scheme.isNotEmpty ? u.scheme : scheme;
          final pathAndQuery = '${u.path}${u.hasQuery ? '?${u.query}' : ''}';
          // overrideHost may include port (e.g. 'example.com:8000')
          return '$schemeUsed://$overrideHost$pathAndQuery';
        } catch (_) {
          return raw.replaceAll('localhost', overrideHost);
        }
      }
      return rewriteLocalhost(raw);
    }

    // 1) Try mediaUrl if provided
    if (mediaUrl != null && mediaUrl.trim().isNotEmpty) {
      final maybe = rewrite(mediaUrl);
      try {
        final uri = Uri.parse(maybe);
        final bytes = await tryGetBytes(uri);
        if (bytes != null) return bytes;
      } catch (_) {}
    }

    // 2) Try filePath with common prefixes (serve paths usually outside api prefix)
    if (filePath != null && filePath.trim().isNotEmpty) {
      final prefixes = [
        '$baseHost/storage/',
        '$baseHost/media/',
        '$baseHost/uploads/',
      ];
      for (final p in prefixes) {
        final candidate = rewrite(p + filePath);
        try {
          final uri = Uri.parse(candidate);
          final bytes = await tryGetBytes(uri);
          if (bytes != null) return bytes;
        } catch (_) {}
      }
    }

    // 3) Try reportId media endpoints (use my-reports / all-reports variants)
    if (reportId != null) {
      final candidates = [
        '$apiBase/my-reports/$reportId/media',
        '$apiBase/all-reports/$reportId/media',
        '$apiBase/my-reports/$reportId',
        '$apiBase/all-reports/$reportId',
        '$baseHost/storage/reports/$reportId',
      ];
      for (final url in candidates) {
        final candidate = rewrite(url);
        try {
          final uri = Uri.parse(candidate);
          final bytes = await tryGetBytes(uri);
          if (bytes != null) return bytes;
        } catch (_) {}
      }
    }

    // 4) Last resort: fetch report detail and look for media entries
    if (reportId != null) {
      try {
        final info = await getReportById(reportId);

        if (info['media'] is List && (info['media'] as List).isNotEmpty) {
          final m0 = (info['media'] as List).first;
          if (m0 is Map) {
            // try original_url then media_url then file_name
            final candidates = <String>[];
            if (m0['original_url'] is String)
              candidates.add(m0['original_url'] as String);
            if (m0['media_url'] is String)
              candidates.add(m0['media_url'] as String);
            if (m0['url'] is String) candidates.add(m0['url'] as String);
            if (m0['file_name'] is String)
              candidates.add(m0['file_name'] as String);

            for (final c in candidates) {
              final candidate = rewrite(c);
              try {
                final uri = Uri.parse(candidate);
                final bytes = await tryGetBytes(uri);
                if (bytes != null) return bytes;
              } catch (_) {}
            }
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

    // Try my-reports / all-reports endpoints
    final candidates = [
      '$apiBase/my-reports/$id',
      '$apiBase/all-reports/$id',
      '$apiBase/my-reports/$id?include=media',
      '$apiBase/all-reports/$id?include=media',
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
        print('getReportById trying $url -> ${res.statusCode}');
        if (res.statusCode >= 200 &&
            res.statusCode < 300 &&
            res.body.trim().isNotEmpty) {
          final decoded = json.decode(res.body.trim());
          if (decoded is Map &&
              decoded.containsKey('data') &&
              decoded['data'] is Map) {
            return Map<String, dynamic>.from(decoded['data']);
          }
          if (decoded is Map) return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    throw HttpException('Failed to fetch report details');
  }
}
