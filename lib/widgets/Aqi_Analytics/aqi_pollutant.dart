import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class AqiPollutant extends StatelessWidget {
  final double pm25;
  final double pm10;
  final double no2;
  final double co;
  final double nh3;
  final double no;
  final double o3;
  final double so2;

  const AqiPollutant({
    super.key,
    required this.pm25,
    required this.pm10,
    required this.no2,
    required this.so2,
    required this.co,
    required this.nh3,
    required this.no,
    required this.o3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pollutants',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: black,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              PollutantCard(
                label: 'PM2.5',
                value: pm25.toStringAsFixed(1),
                unit: 'µg/m³',
              ),
              const SizedBox(width: 12),
              PollutantCard(
                label: 'PM10',
                value: pm10.toStringAsFixed(1),
                unit: 'µg/m³',
              ),
              const SizedBox(width: 12),
              PollutantCard(
                label: 'NO2',
                value: no2.toStringAsFixed(1),
                unit: 'µg/m³',
              ),
              const SizedBox(width: 12),
              PollutantCard(
                label: 'CO',
                value: co.toStringAsFixed(1),
                unit: 'µg/m³',
              ),
              const SizedBox(width: 12),
              PollutantCard(
                label: 'SO2',
                value: so2.toStringAsFixed(1),
                unit: 'µg/m³',
              ),
              const SizedBox(width: 12),
              PollutantCard(
                label: 'NH3',
                value: nh3.toStringAsFixed(1),
                unit: 'µg/m³',
              ),
              const SizedBox(width: 12),
              PollutantCard(
                label: 'O3',
                value: o3.toStringAsFixed(1),
                unit: 'µg/m³',
              ),
              const SizedBox(width: 12),
              PollutantCard(
                label: 'NO',
                value: no.toStringAsFixed(1),
                unit: 'µg/m³',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Pollutant Card Widget
class PollutantCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const PollutantCard({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.28,
      height: MediaQuery.sizeOf(context).height * 0.22,
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
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(unit, style: TextStyle(fontSize: 12, color: grey)),
        ],
      ),
    );
  }
}
