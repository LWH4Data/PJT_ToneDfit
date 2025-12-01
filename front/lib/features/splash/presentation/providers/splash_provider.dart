import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cloth/data/category_data.dart';
import '../../../cloth/presentation/providers/product_providers.dart';
import '../../../category/domain/entities/category_large.dart';
import '../../../weather/presentation/providers/weather_provider.dart';
import '../../../cloth/data/remote/cloth_api_service.dart';
import '../../../cloth/domain/entities/cloth_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Splash 로딩 상태
class SplashState {
  final bool isDataLoaded;
  final bool isLoading;
  final String loadingMessage;

  const SplashState({
    this.isDataLoaded = false,
    this.isLoading = true,
    this.loadingMessage = '데이터를 불러오는 중...',
  });

  SplashState copyWith({
    bool? isDataLoaded,
    bool? isLoading,
    String? loadingMessage,
  }) {
    return SplashState(
      isDataLoaded: isDataLoaded ?? this.isDataLoaded,
      isLoading: isLoading ?? this.isLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
    );
  }
}

/// Splash State Notifier
class SplashNotifier extends Notifier<SplashState> {
  @override
  SplashState build() {
    return const SplashState();
  }

  Future<void> loadMainPageData() async {
    try {
      // 1단계: 인증 체크
      _updateLoadingState(true, '앱 준비 중...');
      print('🔐 [Splash] 인증 체크 시작...');
      await ref.read(authControllerProvider).initFromStorage();
      
      _updateLoadingState(true, '카테고리 데이터를 불러오는 중...');
      
      // 카테고리 데이터 로드
      await Future.delayed(const Duration(milliseconds: 300));
      final genders = CategoryData.getGenders();
      
      if (genders.isEmpty) {
        throw Exception('카테고리 데이터 로딩 실패');
      }
      
      _updateLoadingState(true, '날씨 정보를 불러오는 중...');
      
      // 1. 날씨 정보 먼저 로드
      print('🌤️ [Splash] 날씨 정보 로드 중...');
      await ref.read(weatherProvider.notifier).loadWeather();
      
      final weather = ref.read(weatherProvider).value;
      if (weather == null) {
        throw Exception('날씨 정보 로딩 실패');
      }
      
      final apparentTemp = weather.temperatureFeelsLike;
      print('🌡️ [Splash] 체감온도: $apparentTemp°C');
      
      _updateLoadingState(true, '앱 준비 중...');
      
      // 2. 성별 + 대분류 조합으로 상품 로드 (병렬 호출)
      print('🛍️ [Splash] 성별 및 대분류별 상품 로드 중... (병렬 호출)');
      
      final apiService = ref.read(clothApiServiceProvider);
      
      // 먼저 데이터 클리어
      ref.read(temperatureProductsProvider.notifier).clear();
      
      // 모든 API 호출을 병렬로 실행
      final futures = <Future<void>>[];
      
      for (final gender in genders) {
        for (final largeCategory in gender.larges) {
          // 각 조합마다 Future 생성
          final future = _loadCategoryProducts(
            ref,
            apiService,
            apparentTemp,
            gender.name,
            largeCategory.name,
          );
          futures.add(future);
        }
      }
      
      // 모든 API 호출을 병렬로 실행
      print('🚀 [Splash] ${futures.length}개 API를 병렬로 호출 중...');
      await Future.wait(futures);
      
      final totalCount = ref.read(temperatureProductsProvider).value?.length ?? 0;
      print('✅ [Splash] 총 ${totalCount}개 상품 로드 완료');
      
      state = state.copyWith(
        isLoading: false,
        loadingMessage: '완료!',
        isDataLoaded: true,
      );
    } catch (e) {
      print('❌ [Splash] 로딩 실패: $e');
      state = state.copyWith(
        isLoading: false,
        loadingMessage: '로딩 실패: ${e.toString()}',
        isDataLoaded: false,
      );
    }
  }

  void _updateLoadingState(bool isLoading, String message) {
    state = state.copyWith(
      isLoading: isLoading,
      loadingMessage: message,
    );
  }
  
  /// 카테고리별 상품 로드 (병렬 호출용 헬퍼)
  static Future<void> _loadCategoryProducts(
    Ref ref,
    ClothApiService apiService,
    num apparentTemp,
    String genderName,
    String largeCategoryName,
  ) async {
    try {
      // 첫 페이지 호출
      final firstResponse = await apiService.filterProducts(
        apparentTemp: apparentTemp,
        gender: genderName,
        largeCategory: largeCategoryName,
        page: 1,
        pageSize: 100,
      );
      
      // 즉시 화면에 추가
      ref.read(temperatureProductsProvider.notifier).addProducts(firstResponse.products);
      print('✓ [Splash] $genderName > $largeCategoryName: ${firstResponse.products.length}/${firstResponse.total}개');
      
      // total이 100개보다 많으면 추가 페이지 호출
      if (firstResponse.total > 100) {
        final totalPages = (firstResponse.total / 100).ceil();
        final pageFutures = <Future<void>>[];
        
        for (int pageNum = 2; pageNum <= totalPages; pageNum++) {
          final pageFuture = apiService.filterProducts(
            apparentTemp: apparentTemp,
            gender: genderName,
            largeCategory: largeCategoryName,
            page: pageNum,
            pageSize: 100,
          ).then((pageResponse) {
            ref.read(temperatureProductsProvider.notifier).addProducts(pageResponse.products);
            print('✓ [Splash] $genderName > $largeCategoryName 페이지 $pageNum: ${pageResponse.products.length}개');
          });
          pageFutures.add(pageFuture);
        }
        
        // 모든 페이지 병렬 호출
        await Future.wait(pageFutures);
      }
    } catch (e) {
      print('⚠️ [Splash] $genderName > $largeCategoryName 로드 실패: $e');
    }
  }
}

/// Splash Provider
final splashProvider = NotifierProvider<SplashNotifier, SplashState>(
  SplashNotifier.new,
);











