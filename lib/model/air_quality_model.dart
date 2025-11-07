// lib/model/air_quality_model.dart

class AirQualityModel {
  final Coord coord;
  final List<AirQualityData> list;

  AirQualityModel({required this.coord, required this.list});

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    return AirQualityModel(
      coord: Coord.fromJson(json['coord']),
      list: (json['list'] as List)
          .map((item) => AirQualityData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coord': coord.toJson(),
      'list': list.map((item) => item.toJson()).toList(),
    };
  }
}

class Coord {
  final double lon;
  final double lat;

  Coord({required this.lon, required this.lat});

  factory Coord.fromJson(Map<String, dynamic> json) {
    return Coord(
      lon: (json['lon'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'lon': lon, 'lat': lat};
  }
}

class AirQualityData {
  final MainAqi main;
  final Components components;
  final int dt;

  AirQualityData({
    required this.main,
    required this.components,
    required this.dt,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      main: MainAqi.fromJson(json['main']),
      components: Components.fromJson(json['components']),
      dt: json['dt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'main': main.toJson(), 'components': components.toJson(), 'dt': dt};
  }

  // Convert OpenWeatherMap AQI (1-5) to EPA AQI scale (0-500)
  int getEpaAqi() {
    // OpenWeatherMap AQI scale: 1=Good, 2=Fair, 3=Moderate, 4=Poor, 5=Very Poor
    // Converting to approximate EPA scale
    switch (main.aqi) {
      case 1:
        return 25; // Good (0-50)
      case 2:
        return 75; // Moderate (51-100)
      case 3:
        return 125; // Unhealthy for Sensitive (101-150)
      case 4:
        return 175; // Unhealthy (151-200)
      case 5:
        return 250; // Very Unhealthy (201-300)
      default:
        return 0;
    }
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(dt * 1000);
}

class MainAqi {
  final int aqi;

  MainAqi({required this.aqi});

  factory MainAqi.fromJson(Map<String, dynamic> json) {
    return MainAqi(aqi: json['aqi']);
  }

  Map<String, dynamic> toJson() {
    return {'aqi': aqi};
  }
}

class Components {
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final double nh3;

  Components({
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
  });

  factory Components.fromJson(Map<String, dynamic> json) {
    return Components(
      co: (json['co'] as num).toDouble(),
      no: (json['no'] as num).toDouble(),
      no2: (json['no2'] as num).toDouble(),
      o3: (json['o3'] as num).toDouble(),
      so2: (json['so2'] as num).toDouble(),
      pm2_5: (json['pm2_5'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      nh3: (json['nh3'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'co': co,
      'no': no,
      'no2': no2,
      'o3': o3,
      'so2': so2,
      'pm2_5': pm2_5,
      'pm10': pm10,
      'nh3': nh3,
    };
  }
}
