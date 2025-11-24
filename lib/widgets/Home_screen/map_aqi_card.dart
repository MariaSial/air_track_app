import 'package:air_track_app/model/air_quality_model.dart';
import 'package:air_track_app/services/air_quality_service.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapAqiCard extends StatefulWidget {
  const MapAqiCard({Key? key}) : super(key: key);

  @override
  State<MapAqiCard> createState() => _MapAqiCardState();
}

class _MapAqiCardState extends State<MapAqiCard> {
  final AirQualityService _aqService = AirQualityService();
  final MapController _mapController = MapController();

  LatLng? _selectedLatLng;
  AirQualityModel? _aqModel;
  bool _loading = false;

  // Pakistan approximate bounds
  final LatLng _pakistanSW = LatLng(23.6345, 60.8720);
  final LatLng _pakistanNE = LatLng(37.0841, 77.8375);

  @override
  void initState() {
    super.initState();
    _setInitialLocation();
  }

  Future<void> _setInitialLocation() async {
    try {
      final pos = await _aqService.getCurrentLocation();
      if (pos != null) {
        final initial = LatLng(pos.latitude, pos.longitude);
        if (_isInsidePakistan(initial)) {
          _mapController.move(initial, 6.0);
          await _fetchAqiFor(initial);
          return;
        }
      }
    } catch (e, st) {
      debugPrint('Error getting location: $e');
    }

    // fallback location
    final fallback = LatLng(34.168, 71.726); // Charsadda
    _mapController.move(fallback, 6.0);
    await _fetchAqiFor(fallback);
  }

  bool _isInsidePakistan(LatLng latlng) {
    return latlng.latitude >= _pakistanSW.latitude &&
        latlng.latitude <= _pakistanNE.latitude &&
        latlng.longitude >= _pakistanSW.longitude &&
        latlng.longitude <= _pakistanNE.longitude;
  }

  Future<void> _fetchAqiFor(LatLng latlng) async {
    setState(() {
      _loading = true;
      _aqModel = null;
      _selectedLatLng = latlng;
    });

    try {
      final model = await _aqService.getAirQualityForLocation(
        latlng.latitude,
        latlng.longitude,
        'Today',
      );

      setState(() {
        _aqModel = model;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('Error fetching AQI: $e');
      setState(() {
        _aqModel = null;
        _loading = false;
      });
    }
  }

  Map<String, dynamic> _aqiInfo(int aqi) {
    if (aqi <= 1) return {'label': 'Good', 'color': green};
    if (aqi <= 2) return {'label': 'Moderate', 'color': yellow};
    if (aqi <= 3)
      return {'label': 'Unhealthy for Sensitive Groups', 'color': orange};
    if (aqi <= 4) return {'label': 'Unhealthy', 'color': red};
    if (aqi <= 5) return {'label': 'Very Unhealthy', 'color': purple};
    return {'label': 'Hazardous', 'color': Colors.brown};
  }

  LatLng _clampToPakistan(LatLng latlng) {
    double lat = latlng.latitude.clamp(
      _pakistanSW.latitude,
      _pakistanNE.latitude,
    );
    double lon = latlng.longitude.clamp(
      _pakistanSW.longitude,
      _pakistanNE.longitude,
    );
    return LatLng(lat, lon);
  }

  @override
  Widget build(BuildContext context) {
    final marker = (_selectedLatLng != null)
        ? Marker(
            point: _selectedLatLng!,
            width: 48,
            height: 48,
            child: const Icon(Icons.location_on, size: 40, color: Colors.cyan),
          )
        : null;

    final int? aqiValue = (_aqModel != null && _aqModel!.list.isNotEmpty)
        ? _aqModel!.list[0].main.aqi
        : null;
    final aqiInfo = aqiValue != null ? _aqiInfo(aqiValue) : null;

    String locationLabel = _selectedLatLng != null
        ? 'Lat: ${_selectedLatLng!.latitude.toStringAsFixed(4)}, '
              'Lon: ${_selectedLatLng!.longitude.toStringAsFixed(4)}'
        : 'Loading...';

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.45,
      width: MediaQuery.sizeOf(context).width * 0.95,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(12),
      child: Stack(
        children: [
          // Map
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLatLng ?? LatLng(34.168, 71.726),
                initialZoom: 6.0,
                minZoom: 5.0,
                maxZoom: 10.0,
                onPositionChanged: (pos, _) {
                  if (pos.center != null) {
                    final clamped = _clampToPakistan(pos.center!);
                    if (clamped != pos.center) {
                      _mapController.move(clamped, pos.zoom ?? 6.0);
                    }
                  }
                },
                onTap: (tapPosition, latlng) {
                  if (_isInsidePakistan(latlng)) {
                    _fetchAqiFor(latlng);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.airtrack.airtrack_app',
                ),
                if (marker != null) MarkerLayer(markers: [marker]),
              ],
            ),
          ),
          // AQI info card
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: black, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locationLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  if (_loading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (aqiValue == null)
                    const Text(
                      'AQI not available',
                      style: TextStyle(fontSize: 12),
                    )
                  else ...[
                    Text(
                      'AQI value: $aqiValue',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aqiInfo!['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: (aqiInfo['color'] as Color?) ?? black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
