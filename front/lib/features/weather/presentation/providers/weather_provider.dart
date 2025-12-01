import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/weather_api_service.dart';
import '../../domain/entities/weather_entity.dart';

/// WeatherApiService Provider
final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  return WeatherApiService();
});

/// 날씨 정보 Provider
class WeatherNotifier extends AsyncNotifier<WeatherEntity?> {
  @override
  Future<WeatherEntity?> build() async {
    // 초기값은 null
    return null;
  }
  
  /// 날씨 정보 로드
  Future<void> loadWeather() async {
    try {
      state = const AsyncValue.loading();
      final apiService = ref.read(weatherApiServiceProvider);
      final weather = await apiService.getForecast();
      state = AsyncValue.data(weather);
    } catch (e, stackTrace) {
      print('날씨 로드 실패: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// 날씨 정보 초기화
  void clear() {
    state = const AsyncValue.data(null);
  }
}

final weatherProvider = AsyncNotifierProvider<WeatherNotifier, WeatherEntity?>(
  WeatherNotifier.new,
);

