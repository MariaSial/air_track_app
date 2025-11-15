// lib/view/aqi_analytics/aqi_analytics_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:air_track_app/widgets/Aqi_Analytics/aqi_app_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/aqi_bottom_nav_bar.dart';
import 'package:air_track_app/widgets/Aqi_Analytics/loading_state.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';

import 'package:air_track_app/view/aqi_analytics/daily_view.dart';
import 'package:air_track_app/view/aqi_analytics/historical_view.dart';
import 'package:air_track_app/providers/aqi_analytics_provider.dart';

class AqiAnalyticsView extends ConsumerStatefulWidget {
  const AqiAnalyticsView({Key? key}) : super(key: key);

  @override
  ConsumerState<AqiAnalyticsView> createState() => _AqiAnalyticsViewState();
}

class _AqiAnalyticsViewState extends ConsumerState<AqiAnalyticsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // initialize controller after first frame to avoid sync issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aqiAnalyticsProvider).init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRetry() async {
    await ref.read(aqiAnalyticsProvider).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(aqiAnalyticsProvider);

    return Scaffold(
      body: AppScaffold(
        child: SafeArea(
          child: Column(
            children: [
              AqiAppBar(title: 'AQI Analytics'),
              Expanded(
                child: controller.isLoading
                    ? LoadingState()
                    : controller.errorMessage != null
                    ? ErrorStateWidget(
                        errorMessage: controller.errorMessage!,
                        onRetry: _onRetry,
                      )
                    : controller.airQualityData == null
                    ? Center(child: Text('No data available'))
                    : _buildContentState(controller),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AqiBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildContentState(AqiAnalyticsController controller) {
    if (controller.selectedTimePeriod == 'Today') {
      return DailyView(
        searchController: _searchController,
        timePeriods: controller.timePeriods,
        selectedTimePeriod: controller.selectedTimePeriod,
        onTimePeriodChanged: (v) =>
            controller.setTimePeriod(v ?? controller.selectedTimePeriod),
        onRefresh: controller.refresh,
        locationName: controller.locationName,
        airQualityData: controller.airQualityData!,
        airQualityService: ref.read(airQualityServiceProvider),
        onLocationSelected: (lat, lon, name) =>
            controller.loadAirQualityForSearchedLocation(lat, lon, name),
      );
    } else {
      return HistoricalView(
        searchController: _searchController,
        timePeriods: controller.timePeriods,
        selectedTimePeriod: controller.selectedTimePeriod,
        onTimePeriodChanged: (v) =>
            controller.setTimePeriod(v ?? controller.selectedTimePeriod),
        onRefresh: controller.refresh,
        locationName: controller.locationName,
        airQualityData: controller.airQualityData!,
        airQualityService: ref.read(airQualityServiceProvider),
        onLocationSelected: (lat, lon, name) =>
            controller.loadAirQualityForSearchedLocation(lat, lon, name),
      );
    }
  }
}
