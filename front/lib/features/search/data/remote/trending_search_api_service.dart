import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/trending_keyword_entity.dart';

/// 인기 검색어 API 서비스
class TrendingSearchApiService {
  final AiDioClient _aiDioClient = AiDioClient();

  /// 인기 검색어 조회
  Future<TrendingKeywordsResponse> getTrendingKeywords() async {
    final response = await _aiDioClient.get(
      ApiEndpoints.aiSearchTrending,
    );
    
    return TrendingKeywordsResponse.fromJson(response.data);
  }
}

