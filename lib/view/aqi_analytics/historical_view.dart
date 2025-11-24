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

    widget.searchController.text = displayName;
    setState(() {
      _showSearchResults = false;
    });

    final lat = (location['lat'] as num).toDouble();
    final lon = (location['lon'] as num).toDouble();
    widget.onLocationSelected(lat, lon, displayName);
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
                prefixIcon: const Icon(Icons.search),
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
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: _searchResults.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
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
                                    (result['state'] as String).isNotEmpty
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
                const Padding(
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: grey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.selectedTimePeriod,
                dropdownColor: darkgrey,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(fontSize: 14, color: Colors.white),
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
                      DateTime date = dayData['dateTime'] as DateTime;
                      int aqi = dayData['aqiValue'] as int;
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
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
                              (dayData['pm2_5'] as double).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              (dayData['pm10'] as double).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              (dayData['no2'] as double).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              (dayData['so2'] as double).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              (dayData['co'] as double).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              (dayData['o3'] as double).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              (dayData['nh3'] as double).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DataCell(
                            Text(
                              (dayData['no'] as double).toStringAsFixed(1),
                              style: const TextStyle(fontSize: 13),
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

/// Daily averages calculator
class DailyAveragesCalculator {
  static Map<String, List<dynamic>> groupDataByDay(
    AirQualityModel airQualityData,
  ) {
    Map<String, List<dynamic>> groupedData = {};

    for (var data in airQualityData.list) {
      // use the local date components to build the key
      final localDt = data.dateTime.toLocal();
      String dateKey =
          '${localDt.year}-${localDt.month.toString().padLeft(2, '0')}-${localDt.day.toString().padLeft(2, '0')}';

      groupedData.putIfAbsent(dateKey, () => []);
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

    // today's key for comparison (local)
    final now = DateTime.now().toLocal();
    final String todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    groupedData.forEach((dateKey, dataList) {
      // find the latest reading for the day (by timestamp)
      var latestItem = dataList.reduce(
        (a, b) => (a.dateTime.toLocal().isAfter(b.dateTime.toLocal())) ? a : b,
      );

      // accumulate pollutant sums
      double sumPm25 = 0,
          sumPm10 = 0,
          sumNo2 = 0,
          sumSo2 = 0,
          sumCo = 0,
          sumNh3 = 0,
          sumNo = 0,
          sumO3 = 0;
      double totalAqi = 0;

      for (var data in dataList) {
        totalAqi += data.getEpaAqi();
        sumPm25 += data.components.pm2_5;
        sumPm10 += data.components.pm10;
        sumNo2 += data.components.no2;
        sumSo2 += data.components.so2;
        sumCo += data.components.co;
        sumNh3 += data.components.nh3;
        sumNo += data.components.no;
        sumO3 += data.components.o3;
      }

      int count = dataList.length;

      // For the *current day* use the latest reading's EPA AQI (so it matches Today view)
      int aqiValue;
      DateTime dateTimeForRow;
      if (dateKey == todayKey) {
        aqiValue = latestItem.getEpaAqi();
        dateTimeForRow = latestItem.dateTime.toLocal();
      } else {
        aqiValue = (totalAqi / count).round();
        // use latest timestamp of that day for display consistency
        dateTimeForRow = latestItem.dateTime.toLocal();
      }

      dailyAverages.add({
        'dateTime': dateTimeForRow,
        'aqiValue': aqiValue,
        'pm2_5': sumPm25 / count,
        'pm10': sumPm10 / count,
        'no2': sumNo2 / count,
        'so2': sumSo2 / count,
        'co': sumCo / count,
        'nh3': sumNh3 / count,
        'no': sumNo / count,
        'o3': sumO3 / count,
      });
    });

    // sort descending (most recent first)
    dailyAverages.sort(
      (a, b) =>
          (b['dateTime'] as DateTime).compareTo(a['dateTime'] as DateTime),
    );

    // limit days shown depending on period
    int daysToShow = timePeriod == 'Weekly' ? 7 : 30;
    if (dailyAverages.length > daysToShow) {
      dailyAverages = dailyAverages.sublist(0, daysToShow);
    }

    return dailyAverages;
  }
}
