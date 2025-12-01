/// 인기 검색어 엔티티
class TrendingKeywordEntity {
  final int rank;
  final String keyword;
  final int searchCount;

  const TrendingKeywordEntity({
    required this.rank,
    required this.keyword,
    required this.searchCount,
  });

  factory TrendingKeywordEntity.fromJson(Map<String, dynamic> json) {
    return TrendingKeywordEntity(
      rank: json['rank'] as int,
      keyword: json['keyword'] as String,
      searchCount: json['searchCount'] as int? ?? json['search_count'] as int? ?? 0,
    );
  }
}

/// 인기 검색어 응답 엔티티
class TrendingKeywordsResponse {
  final DateTime timestamp;
  final List<TrendingKeywordEntity> keywords;

  const TrendingKeywordsResponse({
    required this.timestamp,
    required this.keywords,
  });

  factory TrendingKeywordsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> keywordsJson = json['keywords'] ?? [];
    final keywords = keywordsJson
        .map((k) => TrendingKeywordEntity.fromJson(k as Map<String, dynamic>))
        .toList();

    return TrendingKeywordsResponse(
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(), // 로컬 시간대로 변환
      keywords: keywords,
    );
  }
}

