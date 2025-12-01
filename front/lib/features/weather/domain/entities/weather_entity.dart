/// 날씨 정보 엔티티
class WeatherEntity {
  // 온도 정보
  final double temperatureCurrent;
  final double temperatureMax;
  final double temperatureMin;
  final double temperatureFeelsLike;
  
  // 강수 및 기상 정보
  final String weatherCondition;
  final String? precipitationType;
  final int? precipitationChance;
  final double? precipitationAmount;
  
  // 바람 및 습도
  final int? humidityCurrent;
  final double? windSpeed;
  
  // 지수 정보
  final int? dustIndex;
  final String? dustCondition;
  final int? uvIndex;
  final String? uvCondition;
  
  const WeatherEntity({
    required this.temperatureCurrent,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.temperatureFeelsLike,
    required this.weatherCondition,
    this.precipitationType,
    this.precipitationChance,
    this.precipitationAmount,
    this.humidityCurrent,
    this.windSpeed,
    this.dustIndex,
    this.dustCondition,
    this.uvIndex,
    this.uvCondition,
  });
  
  factory WeatherEntity.fromJson(Map<String, dynamic> json) {
    return WeatherEntity(
      temperatureCurrent: (json['TMP_CUR'] ?? 0.0).toDouble(),
      temperatureMax: (json['TMP_MAX'] ?? 0.0).toDouble(),
      temperatureMin: (json['TMP_MIN'] ?? 0.0).toDouble(),
      temperatureFeelsLike: (json['TMP_FEEL'] ?? 0.0).toDouble(),
      weatherCondition: json['WTH_COND'] ?? '맑음',
      precipitationType: json['PRC_TYP'],
      precipitationChance: json['PRC_CHNC'],
      precipitationAmount: (json['PRC_AMT'])?.toDouble(),
      humidityCurrent: json['HUM_CUR'],
      windSpeed: (json['WND_SPD'])?.toDouble(),
      dustIndex: json['DUST_IDX'],
      dustCondition: json['DUST_COND'],
      uvIndex: json['UV_IDX'],
      uvCondition: json['UV_COND'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'temperature_current': temperatureCurrent,
      'temperature_max': temperatureMax,
      'temperature_min': temperatureMin,
      'temperature_feels_like': temperatureFeelsLike,
      'weather_condition': weatherCondition,
      'precipitation_type': precipitationType,
      'precipitation_chance': precipitationChance,
      'precipitation_amount': precipitationAmount,
      'humidity_current': humidityCurrent,
      'wind_speed': windSpeed,
      'dust_index': dustIndex,
      'dust_condition': dustCondition,
      'uv_index': uvIndex,
      'uv_condition': uvCondition,
    };
  }
  
  /// 표시할 날씨 상태 반환
  /// precipitationType이 "없음"이 아니면 precipitationType 사용, 그렇지 않으면 weatherCondition 사용
  String getDisplayWeather() {
    if (precipitationType != null && 
        precipitationType != '없음' && 
        precipitationType != '0' && 
        precipitationType!.isNotEmpty) {
      return precipitationType!;
    }
    return weatherCondition;
  }
}

