import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/remote/trending_search_api_service.dart';
import '../domain/entities/trending_keyword_entity.dart';
import '../presentation/widgets/popular_search_item.dart';

/// 인기 검색어 상태
class TrendingSearchState {
  final DateTime? timestamp;
  final List<PopularSearchItem> items;
  final bool isLoading;
  final String? error;

  const TrendingSearchState({
    this.timestamp,
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  TrendingSearchState copyWith({
    DateTime? timestamp,
    List<PopularSearchItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return TrendingSearchState(
      timestamp: timestamp ?? this.timestamp,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// 인기 검색어 Notifier
class TrendingSearchNotifier extends Notifier<TrendingSearchState> {
  final TrendingSearchApiService _apiService = TrendingSearchApiService();
  
  // 이전 순위 데이터 저장 (순위 변동 계산용)
  Map<String, int> _previousRanks = {};

  @override
  TrendingSearchState build() {
    return const TrendingSearchState();
  }

  /// 인기 검색어 로드
  Future<void> loadTrendingKeywords() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final response = await _apiService.getTrendingKeywords();
      
      // 순위 변동 계산
      final items = _calculateRankChanges(response.keywords);
      
      // 현재 순위를 이전 순위로 저장
      _previousRanks = {
        for (var keyword in response.keywords)
          keyword.keyword: keyword.rank
      };
      
      state = state.copyWith(
        timestamp: response.timestamp,
        items: items,
        isLoading: false,
      );
      
      print('✅ [TrendingSearch] ${items.length}개 인기 검색어 로드 완료');
      print('📅 [TrendingSearch] timestamp: ${response.timestamp}');
      print('📅 [TrendingSearch] 표시 시간: ${response.timestamp.month}월 ${response.timestamp.day}일 ${response.timestamp.hour}시 ${response.timestamp.minute}분');
    } catch (e) {
      print('❌ [TrendingSearch] 로드 실패: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 순위 변동 계산
  List<PopularSearchItem> _calculateRankChanges(List<TrendingKeywordEntity> keywords) {
    return keywords.map((keyword) {
      RankChangeType? rankChange;
      int? changeValue;

      if (_previousRanks.containsKey(keyword.keyword)) {
        // 이전 순위가 있는 경우
        final previousRank = _previousRanks[keyword.keyword]!;
        final currentRank = keyword.rank;
        
        if (previousRank > currentRank) {
          // 순위 상승 (이전 10위 → 현재 5위 = 5단계 상승)
          rankChange = RankChangeType.up;
          changeValue = previousRank - currentRank;
        } else if (previousRank < currentRank) {
          // 순위 하락 (이전 5위 → 현재 10위 = 5단계 하락)
          rankChange = RankChangeType.down;
          changeValue = currentRank - previousRank;
        } else {
          // 순위 변동 없음
          rankChange = RankChangeType.none;
        }
      } else {
        // 이전 순위가 없는 경우 (신규)
        rankChange = RankChangeType.new_;
      }

      return PopularSearchItem(
        rank: keyword.rank,
        keyword: keyword.keyword,
        rankChange: rankChange,
        changeValue: changeValue,
      );
    }).toList();
  }
}

final trendingSearchProvider = NotifierProvider<TrendingSearchNotifier, TrendingSearchState>(
  TrendingSearchNotifier.new,
);

