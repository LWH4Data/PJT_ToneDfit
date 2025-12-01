import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cloth_entity.dart';
import '../../data/remote/cloth_api_service.dart';
import '../../../../core/network/api_exception.dart';

/// API 서비스 Provider
final clothApiServiceProvider = Provider<ClothApiService>((ref) {
  return ClothApiService();
});

/// 선택된 성별 Provider (전역 관리)
class SelectedGenderNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setGender(String? genderName) {
    state = genderName;
  }
  
  void clear() {
    state = null;
  }
}

final selectedGenderProvider = NotifierProvider<SelectedGenderNotifier, String?>(
  SelectedGenderNotifier.new,
);

/// 대분류별 상품 AsyncNotifier
/// Map<"성별_대분류ID", List<ClothEntity>>
class CategoryProductsNotifier extends AsyncNotifier<Map<String, List<ClothEntity>>> {
  @override
  Future<Map<String, List<ClothEntity>>> build() async {
    // 초기에는 빈 맵 반환
    return {};
  }
  
  /// 캐시 키 생성 (성별_대분류ID)
  String _getCacheKey(String? gender, String largeCategoryId) {
    return '${gender ?? "all"}_$largeCategoryId';
  }

  /// 모든 대분류의 상품 로드 (병렬 처리, 성별별 저장)
  Future<void> loadAllCategories({
    required List<String> largeCategoryIds,
    required List<String> largeCategoryNames,
    String? gender,
    bool forceReload = false, // 강제 새로고침
  }) async {
    // 이미 로딩 중이면 생략
    if (state.isLoading) {
      return;
    }
    
    // 이미 해당 성별 데이터가 있으면 생략 (강제 새로고침 제외)
    if (!forceReload && state.hasValue) {
      final currentData = state.value!;
      // 해당 성별의 대분류 중 하나라도 있으면 이미 로드됨
      final hasData = largeCategoryIds.any((id) {
        final key = _getCacheKey(gender, id);
        return currentData.containsKey(key);
      });
      if (hasData) return;
    }

    try {
      final apiService = ref.read(clothApiServiceProvider);
      
      // 병렬로 모든 API 호출 실행
      final futures = List.generate(
        largeCategoryIds.length,
        (i) async {
          final id = largeCategoryIds[i];
          final name = largeCategoryNames[i];
          
          try {
            // 첫 페이지 호출
            final firstResponse = await apiService.filterProducts(
              gender: gender,
              largeCategory: name,
              page: 1,
              pageSize: 100,
            );
            
            final allProducts = <ClothEntity>[...firstResponse.products];
            
            // total이 100개보다 많으면 추가 페이지 호출
            if (firstResponse.total > 100) {
              final totalPages = (firstResponse.total / 100).ceil();
              
              for (int pageNum = 2; pageNum <= totalPages; pageNum++) {
                final pageResponse = await apiService.filterProducts(
                  gender: gender,
                  largeCategory: name,
                  page: pageNum,
                  pageSize: 100,
                );
                
                allProducts.addAll(pageResponse.products);
              }
            }
            
            if (allProducts.isNotEmpty) {
              // 성별_대분류ID 형식으로 저장
              final cacheKey = _getCacheKey(gender, id);
              return MapEntry(cacheKey, allProducts);
            }
          } catch (e) {
            // 에러 발생 시 null 반환
            return null;
          }
          return null;
        },
      );
      
      // 모든 API 호출이 완료될 때까지 대기
      final results = await Future.wait(futures);
      
      // 기존 데이터와 병합
      final currentData = state.hasValue ? state.value! : <String, List<ClothEntity>>{};
      final newData = Map<String, List<ClothEntity>>.from(currentData);
      
      for (final result in results) {
        if (result != null) {
          newData[result.key] = result.value;
        }
      }

      state = AsyncValue.data(newData);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
  
  /// 특정 성별의 대분류 상품 가져오기
  Map<String, List<ClothEntity>> getProductsByGender(String? gender, List<String> largeCategoryIds) {
    if (!state.hasValue) return {};
    
    final currentData = state.value!;
    final result = <String, List<ClothEntity>>{};
    
    for (final id in largeCategoryIds) {
      final key = _getCacheKey(gender, id);
      if (currentData.containsKey(key)) {
        result[id] = currentData[key]!;
      }
    }
    
    return result;
  }
}

final categoryProductsProvider = AsyncNotifierProvider<CategoryProductsNotifier, Map<String, List<ClothEntity>>>(
  CategoryProductsNotifier.new,
);

// 소분류별 상품 개수 체크 로직 제거 (카테고리 하드코딩 사용으로 불필요)

/// 소분류별 상품 데이터 캐시 (전역 관리)
/// Map<"성별_대분류_소분류", List<ClothEntity>>
class SmallCategoryProductsCacheNotifier extends Notifier<Map<String, List<ClothEntity>>> {
  @override
  Map<String, List<ClothEntity>> build() => {};

  /// 캐시 키 생성
  String _getCacheKey(String? gender, String largeCategory, String smallCategory) {
    return '${gender ?? "all"}_${largeCategory}_$smallCategory';
  }

  /// 캐시에서 데이터 가져오기
  List<ClothEntity>? get(String? gender, String largeCategory, String smallCategory) {
    final key = _getCacheKey(gender, largeCategory, smallCategory);
    return state[key];
  }

  /// 캐시에 데이터 저장
  void set(String? gender, String largeCategory, String smallCategory, List<ClothEntity> products) {
    final key = _getCacheKey(gender, largeCategory, smallCategory);
    state = {...state, key: products};
  }

  /// 캐시 여부 확인
  bool hasCache(String? gender, String largeCategory, String smallCategory) {
    final key = _getCacheKey(gender, largeCategory, smallCategory);
    return state.containsKey(key);
  }

  /// 소분류 상품 로드 (캐시 우선)
  Future<List<ClothEntity>> loadProducts({
    required String? gender,
    required String largeCategory,
    required String smallCategory,
  }) async {
    // 캐시 확인
    if (hasCache(gender, largeCategory, smallCategory)) {
      return get(gender, largeCategory, smallCategory)!;
    }

    // 캐시에 없으면 API 호출
    final apiService = ref.read(clothApiServiceProvider);
    
    // 첫 페이지 호출
    final firstResponse = await apiService.filterProducts(
      gender: gender,
      largeCategory: largeCategory,
      smallCategory: smallCategory,
      page: 1,
      pageSize: 100,
    );
    
    final allProducts = <ClothEntity>[...firstResponse.products];
    
    // total이 100개보다 많으면 추가 페이지 호출
    if (firstResponse.total > 100) {
      final totalPages = (firstResponse.total / 100).ceil();
      
      for (int pageNum = 2; pageNum <= totalPages; pageNum++) {
        final pageResponse = await apiService.filterProducts(
          gender: gender,
          largeCategory: largeCategory,
          smallCategory: smallCategory,
          page: pageNum,
          pageSize: 100,
        );
        
        allProducts.addAll(pageResponse.products);
      }
    }

    // 캐시에 저장
    set(gender, largeCategory, smallCategory, allProducts);
    
    return allProducts;
  }
}

final smallCategoryProductsCacheProvider = NotifierProvider<SmallCategoryProductsCacheNotifier, Map<String, List<ClothEntity>>>(
  SmallCategoryProductsCacheNotifier.new,
);

/// 온도 기반 추천 상품 AsyncNotifier
class TemperatureProductsNotifier extends AsyncNotifier<List<ClothEntity>> {
  @override
  Future<List<ClothEntity>> build() async {
    // 초기에는 빈 리스트 반환
    return [];
  }

  /// 온도 기반 상품 로드
  Future<void> loadProductsByTemperature(num apparentTemp, {String? gender}) async {
    try {
      state = const AsyncValue.loading();
      
      final apiService = ref.read(clothApiServiceProvider);
      
      // 첫 페이지 호출
      final firstResponse = await apiService.filterProducts(
        apparentTemp: apparentTemp,
        gender: gender,
        page: 1,
        pageSize: 100,
      );
      
      final allProducts = <ClothEntity>[...firstResponse.products];
      
      // total이 100개보다 많으면 추가 페이지 호출
      if (firstResponse.total > 100) {
        final totalPages = (firstResponse.total / 100).ceil();
        
        for (int pageNum = 2; pageNum <= totalPages; pageNum++) {
          final pageResponse = await apiService.filterProducts(
            apparentTemp: apparentTemp,
            gender: gender,
            page: pageNum,
            pageSize: 100,
          );
          
          allProducts.addAll(pageResponse.products);
        }
      }
      
      state = AsyncValue.data(allProducts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// 상품 목록 직접 설정 (Splash에서 사용)
  void setProducts(List<ClothEntity> products) {
    state = AsyncValue.data(products);
  }
  
  /// 상품 목록에 점진적으로 추가 (로딩 중에도 화면에 표시)
  void addProducts(List<ClothEntity> products) {
    final currentProducts = state.value ?? [];
    state = AsyncValue.data([...currentProducts, ...products]);
  }
  
  /// 데이터 초기화
  void clear() {
    state = const AsyncValue.data([]);
  }
}

final temperatureProductsProvider = AsyncNotifierProvider<TemperatureProductsNotifier, List<ClothEntity>>(
  TemperatureProductsNotifier.new,
);












