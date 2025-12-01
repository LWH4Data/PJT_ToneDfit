import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/weather_entity.dart';

/// 날씨 API 서비스
class WeatherApiService {
  final DioClient _dioClient = DioClient();

  /// 날씨 예보 조회
  /// 
  /// GET /temp/forecast
  Future<WeatherEntity> getForecast() async {
    try {
      final response = await _dioClient.get(
        ApiEndpoints.tempForecast,
      );

      final data = response.data as Map<String, dynamic>;
      return WeatherEntity.fromJson(data);
    } catch (e) {
      print('날씨 조회 실패: $e');
      rethrow;
    }
  }
}

