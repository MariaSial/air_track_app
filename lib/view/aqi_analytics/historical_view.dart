import 'package:air_track_app/model/air_quality_model.dart';
import 'package:air_track_app/services/air_quality_service.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class HistoricalView extends StatefulWidget {
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

  const HistoricalView({
    Key? key,
    required this.searchController,
    required this.timePeriods,
    required this.selectedTimePeriod,
    required this.onTimePeriodChanged,
    required this.onRefresh,
    required this.locationName,
    required this.airQualityService,
    required this.onLocationSelected,
    required this.airQualityData,
  }) : super(key: key);

  @override
  State<HistoricalView> createState() => _HistoricalViewState();
}

class _HistoricalViewState extends State<HistoricalView> {
  bool _showSearchResults = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow[700]!;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return maroon;
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
    List<Map<String, dynamic>> dailyData =
        DailyAveragesCalculator.calculateDailyAverages(
          widget.airQualityData,
          widget.selectedTimePeriod,
        );

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
                hintText: "Search",
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

          // Dropdown and Refresh Button Row
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

          // Single Card with Table
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  '${widget.selectedTimePeriod} Air Quality History',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${dailyData.length} days of data (daily averages)',
                  style: TextStyle(fontSize: 14, color: grey),
                ),
                const SizedBox(height: 16),

                // Horizontal Scrollable Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      blue.withOpacity(0.1),
                    ),
                    border: TableBorder.all(color: Colors.grey[300]!, width: 1),
                    columnSpacing: 16,
                    dataRowMinHeight: 48,
                    dataRowMaxHeight: 60,
                    columns: [
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'AQI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'PM2.5',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'PM10',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'NO₂',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'SO₂',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'CO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'O₃',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'NO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'NH₃',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                      ),
                    ],
                    rows: dailyData.map((dayData) {
                      DateTime date = dayData['dateTime'];
                      int aqi = dayData['aqiValue'];
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getAqiColor(aqi).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _getAqiColor(aqi),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                aqi.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getAqiColor(aqi),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              dayData['pm2_5'].toStringAsFixed(1),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              dayData['pm10'].toStringAsFixed(1),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              dayData['no2'].toStringAsFixed(1),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              dayData['so2'].toStringAsFixed(1),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              dayData['co'].toStringAsFixed(1),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              dayData['o3'].toStringAsFixed(1),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              dayData['nh3'].toStringAsFixed(1),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              dayData['no'].toStringAsFixed(1),
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Daily averages calculator
class DailyAveragesCalculator {
  static Map<String, List<dynamic>> groupDataByDay(
    AirQualityModel airQualityData,
  ) {
    Map<String, List<dynamic>> groupedData = {};

    for (var data in airQualityData.list) {
      String dateKey =
          '${data.dateTime.year}-${data.dateTime.month.toString().padLeft(2, '0')}-${data.dateTime.day.toString().padLeft(2, '0')}';

      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }
      groupedData[dateKey]!.add(data);
    }

    return groupedData;
  }

  static List<Map<String, dynamic>> calculateDailyAverages(
    AirQualityModel airQualityData,
    String timePeriod,
  ) {
    var groupedData = groupDataByDay(airQualityData);
    List<Map<String, dynamic>> dailyAverages = [];

    groupedData.forEach((dateKey, dataList) {
      double avgPm25 = 0,
          avgPm10 = 0,
          avgNo2 = 0,
          avgSo2 = 0,
          avgCo = 0,
          avgNh3 = 0,
          avgNo = 0,
          avgO3 = 0;
      double totalAqi = 0;

      for (var data in dataList) {
        totalAqi += data.getEpaAqi();
        avgPm25 += data.components.pm2_5;
        avgPm10 += data.components.pm10;
        avgNo2 += data.components.no2;
        avgSo2 += data.components.so2;
        avgCo += data.components.co;
        avgNh3 += data.components.nh3;
        avgNo += data.components.no;
        avgO3 += data.components.o3;
      }

      int count = dataList.length;

      dailyAverages.add({
        'dateTime': dataList.first.dateTime,
        'aqiValue': (totalAqi / count).round(),
        'pm2_5': avgPm25 / count,
        'pm10': avgPm10 / count,
        'no2': avgNo2 / count,
        'so2': avgSo2 / count,
        'co': avgCo / count,
        'nh3': avgNh3 / count,
        'no': avgNo / count,
        'o3': avgO3 / count,
      });
    });

    dailyAverages.sort((a, b) => b['dateTime'].compareTo(a['dateTime']));

    int daysToShow = timePeriod == 'Weekly' ? 7 : 30;
    if (dailyAverages.length > daysToShow) {
      dailyAverages = dailyAverages.sublist(0, daysToShow);
    }

    return dailyAverages;
  }
}
