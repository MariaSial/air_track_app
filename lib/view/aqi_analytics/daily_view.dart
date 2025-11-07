import 'package:air_track_app/model/air_quality_model.dart';
import 'package:air_track_app/services/air_quality_service.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_card.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_pollutant.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_status_message.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/location_helper.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/white_text_button.dart';
import 'package:flutter/material.dart';

class DailyView extends StatefulWidget {
  final TextEditingController searchController;
  final List<String> timePeriods;
  final String selectedTimePeriod;
  final Function(String?) onTimePeriodChanged;
  final VoidCallback onRefresh;
  final String locationName;
  final AirQualityModel airQualityData;
  final AirQualityService airQualityService;
  final Function(double lat, double lon, String locationName)
  onLocationSelected;

  const DailyView({
    Key? key,
    required this.searchController,
    required this.timePeriods,
    required this.selectedTimePeriod,
    required this.onTimePeriodChanged,
    required this.onRefresh,
    required this.locationName,
    required this.airQualityData,
    required this.airQualityService,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  bool _showSearchResults = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

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
      final results = await widget.airQualityService.searchLocations(query);
      setState(() {
        _searchResults = results;
        _showSearchResults = results.isNotEmpty;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching: $e');
      setState(() {
        _isSearching = false;
        _showSearchResults = false;
      });
    }
  }

  void _selectLocation(Map<String, dynamic> location) {
    final displayName =
        location['state'] != null && location['state'].isNotEmpty
        ? '${location['name']}, ${location['state']}, Pakistan'
        : '${location['name']}, Pakistan';

    widget.searchController.text = displayName;
    setState(() {
      _showSearchResults = false;
    });

    widget.onLocationSelected(location['lat'], location['lon'], displayName);
  }

  @override
  Widget build(BuildContext context) {
    final aqiData = widget.airQualityData.list.first;
    final epaAqi = aqiData.getEpaAqi();
    final components = aqiData.components;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar with Results
          Column(
            children: [
              AppTextField(
                controller: widget.searchController,
                hintText: "Search ",
                prefixIcon: Icon(Icons.search),
                onChanged: _searchLocations,
                suffixIcon: widget.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: grey),
                        onPressed: () {
                          widget.searchController.clear();
                          setState(() {
                            _showSearchResults = false;
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
              ),

              // Search Results Dropdown
              if (_showSearchResults)
                Container(
                  margin: EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(maxHeight: 250),
                  child: _searchResults.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No locations found in Pakistan',
                            style: TextStyle(color: grey),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            final subtitle =
                                result['state'] != null &&
                                    result['state'].isNotEmpty
                                ? '${result['state']}, Pakistan'
                                : 'Pakistan';

                            return ListTile(
                              leading: Icon(Icons.location_on, color: blue),
                              title: Text(
                                result['name'],
                                style: TextStyle(fontSize: 14, color: black),
                              ),
                              subtitle: Text(
                                subtitle,
                                style: TextStyle(fontSize: 12, color: grey),
                              ),
                              onTap: () => _selectLocation(result),
                              dense: true,
                            );
                          },
                        ),
                ),

              // Show loading indicator while searching
              if (_isSearching)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Dropdown for Time Period Selection
          Container(
            margin: EdgeInsets.only(
              left: MediaQuery.sizeOf(context).width * 0.55,
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedTimePeriod,
                dropdownColor: darkgrey,
                icon: Icon(Icons.arrow_drop_down, color: white),
                style: TextStyle(fontSize: 14, color: white),
                items: widget.timePeriods.map((String period) {
                  final bool isSelected = widget.selectedTimePeriod == period;
                  return DropdownMenuItem<String>(
                    value: period,
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: widget.onTimePeriodChanged,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // AQI Card
          AqiCard(aqiValue: epaAqi, locationName: widget.locationName),

          const SizedBox(height: 24),

          // Pollutants Section
          AqiPollutant(
            pm25: components.pm2_5,
            pm10: components.pm10,
            no2: components.no2,
            so2: components.so2,
            co: components.co,
            nh3: components.nh3,
            no: components.no,
            o3: components.o3,
          ),

          const SizedBox(height: 24),

          // Status Message
          AqiStatusMessage(aqiValue: epaAqi),

          const SizedBox(height: 16),

          // Last Updated Time
          Center(
            child: Text(
              'Last updated: ${DateFormatter.formatDateTime(aqiData.dateTime)}',
              style: TextStyle(
                fontSize: 12,
                color: grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
