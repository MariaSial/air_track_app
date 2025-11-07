class AirQualityHistoryModel {
  final int id;
  final double lat;
  final double lon;
  final int aqi;
  final double pm2_5;
  final double pm10;
  final double no2;
  final double so2;
  final double co;
  final double nh3;
  final double no;
  final double o3;
  final DateTime createdAt;
  final String city;
  final String country; // Always Pakistan for this app

  AirQualityHistoryModel({
    required this.id,
    required this.lat,
    required this.lon,
    required this.aqi,
    required this.pm2_5,
    required this.pm10,
    required this.no2,
    required this.so2,
    required this.co,
    required this.nh3,
    required this.no,
    required this.o3,
    required this.createdAt,
    required this.city,
    this.country = 'Pakistan', // default value Pakistan
  });

  factory AirQualityHistoryModel.fromJson(Map<String, dynamic> json) {
    return AirQualityHistoryModel(
      id: json['id'] ?? 0,
      lat: (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
      lon: (json['longitude'] ?? json['lon'] ?? 0).toDouble(),
      aqi: (json['aqi'] ?? 0).toInt(),
      pm2_5: (json['pm2_5'] ?? 0).toDouble(),
      pm10: (json['pm10'] ?? 0).toDouble(),
      no2: (json['no2'] ?? 0).toDouble(),
      so2: (json['so2'] ?? 0).toDouble(),
      co: (json['co'] ?? 0).toDouble(),
      nh3: (json['nh3'] ?? 0).toDouble(),
      no: (json['no'] ?? 0).toDouble(),
      o3: (json['o3'] ?? 0).toDouble(),
      createdAt:
          DateTime.tryParse(json['recorded_at'] ?? '') ??
          DateTime.now(), // safely parse
      city: json['city'] ?? 'Unknown',
      country: 'Pakistan', // all data is Pakistan
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': lat,
      'longitude': lon,
      'aqi': aqi,
      'pm2_5': pm2_5,
      'pm10': pm10,
      'no2': no2,
      'so2': so2,
      'co': co,
      'nh3': nh3,
      'no': no,
      'o3': o3,
      'recorded_at': createdAt.toIso8601String(),
      'city': city,
      'country': country,
    };
  }
}
