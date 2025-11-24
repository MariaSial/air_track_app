import 'package:air_track_app/model/air_quality_model.dart';
import 'package:air_track_app/services/air_quality_service.dart';
import 'package:air_track_app/view/home_view/report_pollution_screen.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_bottom_nav_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_card.dart';
import 'package:air_track_app/widgets/Home_screen/map_aqi_card.dart';
import 'package:air_track_app/widgets/Home_screen/weather_card.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:flutter/material.dart';

// Make sure AQIGaugePainter and AQIData are available in scope
// If AQIGaugePainter is in another file, import it too.

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  late final TextEditingController searchController;
  late final AirQualityService airQualityService;

  bool _showSearchResults = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  AirQualityModel? _currentLocationAqi;
  double? _currentLatitude;
  double? _currentLongitude;
  String? _currentLocationName;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    airQualityService = AirQualityService();

    searchController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });

    _fetchCurrentLocationAqi(); // initial fetch
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Fetch AQI for the *device current location*
  Future<void> _fetchCurrentLocationAqi() async {
    try {
      final pos = await airQualityService.getCurrentLocation();
      _currentLatitude = pos?.latitude;
      _currentLongitude = pos?.longitude;

      final aqiData = await airQualityService.getAirQualityForLocation(
        pos!.latitude,
        pos.longitude,
        'Today',
      );

      setState(() {
        _currentLocationAqi = aqiData;
        _currentLocationName = 'Current Location';
      });
    } catch (e) {
      debugPrint('Error fetching AQI: $e');
      // keep previous values if any
    }
  }

  /// Fetch AQI for an arbitrary lat/lon (used when user selects a search result)
  Future<void> _fetchAqiForLatLon(
    double lat,
    double lon,
    String displayName,
  ) async {
    try {
      final aqiData = await airQualityService.getAirQualityForLocation(
        lat,
        lon,
        'Today',
      );

      setState(() {
        _currentLocationAqi = aqiData;
        _currentLatitude = lat;
        _currentLongitude = lon;
        _currentLocationName = displayName;
      });
    } catch (e) {
      debugPrint('Error fetching AQI for selected location: $e');
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _showSearchResults = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await airQualityService.searchLocations(query);
      setState(() {
        _searchResults = results;
        _showSearchResults = results.isNotEmpty;
        _isSearching = false;
      });
    } catch (e) {
      debugPrint('Error searching: $e');
      setState(() {
        _isSearching = false;
        _showSearchResults = false;
      });
    }
  }

  void _selectLocation(Map<String, dynamic> location) {
    final displayName =
        location['state'] != null && (location['state'] as String).isNotEmpty
        ? '${location['name']}, ${location['state']}, Pakistan'
        : '${location['name']}, Pakistan';

    searchController.text = displayName;
    setState(() {
      _showSearchResults = false;
    });

    final lat = (location['lat'] as num).toDouble();
    final lon = (location['lon'] as num).toDouble();

    _fetchAqiForLatLon(lat, lon, displayName); // fetch AQI for selected place
  }

  /// Helper - unify EPA AQI extraction so both widgets use the same value
  int? _getEpaAqiFromModel(AirQualityModel? model) {
    if (model == null) return null;
    if (model.list.isEmpty) return null;
    // use the same helper used in DailyView: getEpaAqi()
    return model.list.first.getEpaAqi();
  }

  @override
  Widget build(BuildContext context) {
    final int? epaAqi = _getEpaAqiFromModel(_currentLocationAqi);
    final AQIData aqiData = epaAqi != null
        ? AQIData.getAQIData(epaAqi)
        : AQIData(label: '-', color: grey);

    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AqiAppBar(title: "Home"),
                AppTextField(
                  controller: searchController,
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  onChanged: _searchLocations,
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: grey),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              _showSearchResults = false;
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
                ),

                if (_showSearchResults)
                  Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (_, i) {
                        final item = _searchResults[i];
                        return ListTile(
                          title: Text(item['name']?.toString() ?? 'Unknown'),
                          subtitle: Text(item['country']?.toString() ?? ''),
                          onTap: () => _selectLocation(item),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Weather Daily Forecast',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 8),
                WeatherCard(),
                const SizedBox(height: 10),

                // AQI Card container (main screen)
                Container(
                  width: MediaQuery.sizeOf(context).width * 0.95,
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: epaAqi == null
                      ? const Center(child: CircularProgressIndicator())
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            // constraints.maxHeight is the available height inside the Container
                            // We'll give the gauge most of that height while keeping a fixed width.
                            final double availableHeight =
                                constraints.maxHeight;
                            // Tune this factor to control how big the gauge appears vertically.
                            final double gaugeHeight = availableHeight * 0.85;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Make the gauge take the computed vertical space and center its painted content
                                Column(
                                  children: [
                                    Text(
                                      "Air Quality Index",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 3.4),
                                    SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: CustomPaint(
                                        // If your painter expects a square area, it will get centered inside this SizedBox.
                                        size: Size(120, 120),
                                        painter: AQIGaugePainter(
                                          value: epaAqi,
                                          color: aqiData.color,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$epaAqi',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Right column remains vertically centered
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Current Status',
                                      style: TextStyle(color: grey),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      aqiData.label,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: aqiData.color,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (_currentLocationName != null)
                                      Text(
                                        _currentLocationName!,
                                        style: TextStyle(
                                          color: grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                ),

                const SizedBox(height: 10),
                MapAqiCard(),
                const SizedBox(height: 20),

                Center(
                  child: BlueButton(
                    text: "Report Pollution",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportPollutionScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AqiBottomNavBar(currentIndex: 0),
    );
  }
}
