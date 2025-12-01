import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/index.dart';
import '../../../shared/utils/navigation_helper.dart';
import '../../cloth/index.dart';
import '../../cloth/presentation/providers/product_providers.dart';
import '../../cloth/presentation/pages/product_list_page.dart';
import '../../cloth/presentation/pages/product_webview_page.dart';
import '../../avatar/index.dart';
import '../../../app/router/app_router.dart';
import '../../category/domain/entities/gender.dart';
import '../../category/domain/entities/category_large.dart';
import '../../category/presentation/widgets/gender_tag_list.dart';
import '../../splash/presentation/providers/splash_provider.dart';
import '../../weather/presentation/providers/weather_provider.dart';
import '../../weather/presentation/widgets/weather_card.dart';
import '../../cloth/data/category_data.dart';
import '../../cloth/data/remote/cloth_api_service.dart';
import '../../cloth/domain/entities/cloth_entity.dart';

// Home feature page
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin, BottomNavScrollMixin {
  int _currentIndex = 0;
  late ScrollController _scrollController;
  
  // 캐릭터 상태
  int _currentCharacterIndex = 0;
  Timer? _characterTimer;
  
  // 날씨 카드 애니메이션 상태
  double _weatherCardTop = AppConstants.weatherCardInitialTop;
  double _headerTop = 0.0;
  double _headerOpacity = 1.0;
  double _weatherCardPadding = AppConstants.defaultPadding;
  double _weatherCardBorderRadius = AppConstants.weatherCardBorderRadius;
  
  // 날씨 모달 상태
  bool _isWeatherModalOpen = false;
  
  // 이전 체감온도 저장 (날씨 변경 감지용)
  double? _previousApparentTemp;
  
  // 날씨 새로고침 중 표시
  bool _isRefreshingWeather = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // 캐릭터 자동 변경 타이머 시작
    _characterTimer = Timer.periodic(AppConstants.characterChangeDuration, (timer) {
      if (mounted) {
        setState(() {
          _currentCharacterIndex = (_currentCharacterIndex + 1) % AppConstants.characterImages.length;
        });
      }
    });
    
    // ⚠️ 초기 로드는 Splash에서 수행됨 (다른 페이지에서 돌아올 때 API 재호출 방지)
    
    // Splash에서 로드한 현재 체감온도 저장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weather = ref.read(weatherProvider).value;
      if (weather != null) {
        _previousApparentTemp = weather.temperatureFeelsLike;
        print('🌡️ [HomePage] 초기 체감온도: $_previousApparentTemp°C');
      }
    });
  }
  
  /// 날씨 정보 로드 및 체감온도 변경 시 상품 재로드
  Future<void> _loadWeather() async {
    print('🌤️ [HomePage] 날씨 정보 로드 중...');
    
    setState(() {
      _isRefreshingWeather = true;
    });
    
    try {
      // 날씨 정보 로드
      await ref.read(weatherProvider.notifier).loadWeather();
      
      // 새로운 날씨 정보 가져오기
      final weather = ref.read(weatherProvider).value;
      if (weather == null) {
        print('❌ [HomePage] 날씨 정보 로드 실패');
        return;
      }
      
      final newApparentTemp = weather.temperatureFeelsLike;
      print('🌡️ [HomePage] 현재 체감온도: $newApparentTemp°C');
      
      // 체감온도가 변경되었는지 확인
      if (_previousApparentTemp == null || _previousApparentTemp != newApparentTemp) {
        print('🔄 [HomePage] 체감온도 변경 감지 ($_previousApparentTemp°C → $newApparentTemp°C)');
        _previousApparentTemp = newApparentTemp;
        
        // 성별 + 대분류 조합으로 상품 재로드 (점진적 로딩)
        await _reloadProductsByGenderAndCategories(newApparentTemp);
      } else {
        print('✓ [HomePage] 체감온도 변경 없음 - 상품 목록 유지');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshingWeather = false;
        });
      }
    }
  }
  
  /// 성별과 대분류 조합으로 상품 재로드 (병렬 호출)
  Future<void> _reloadProductsByGenderAndCategories(num apparentTemp) async {
    print('🛍️ [HomePage] 상품 목록 재로드 중... (병렬 호출)');
    
    final apiService = ref.read(clothApiServiceProvider);
    final genders = CategoryData.getGenders();
    
    // 먼저 기존 데이터 클리어
    ref.read(temperatureProductsProvider.notifier).clear();
    
    // 모든 API 호출을 병렬로 실행
    final futures = <Future<void>>[];
    
    for (final gender in genders) {
      for (final largeCategory in gender.larges) {
        // 각 조합마다 Future 생성
        final future = _loadCategoryProducts(
          apiService,
          apparentTemp,
          gender.name,
          largeCategory.name,
        );
        futures.add(future);
      }
    }
    
    // 모든 API 호출을 병렬로 실행
    print('🚀 [HomePage] ${futures.length}개 API를 병렬로 호출 중...');
    await Future.wait(futures);
    
    final totalCount = ref.read(temperatureProductsProvider).value?.length ?? 0;
    print('✅ [HomePage] 총 ${totalCount}개 상품 재로드 완료');
  }
  
  /// 카테고리별 상품 로드 (병렬 호출용 헬퍼)
  Future<void> _loadCategoryProducts(
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
      print('✓ [HomePage] $genderName > $largeCategoryName: ${firstResponse.products.length}/${firstResponse.total}개');
      
      // total이 100개보다 많으면 추가 페이지 호출 (병렬)
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
            print('✓ [HomePage] $genderName > $largeCategoryName 페이지 $pageNum: ${pageResponse.products.length}개');
          });
          pageFutures.add(pageFuture);
        }
        
        // 모든 페이지 병렬 호출
        await Future.wait(pageFutures);
      }
    } catch (e) {
      print('⚠️ [HomePage] $genderName > $largeCategoryName 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _characterTimer?.cancel(); // 타이머 정리
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = _scrollController.position.pixels;
    
    // 하단 네비게이션 및 대분류 태그 애니메이션 처리 (Mixin 사용)
    handleBottomNavScroll(scrollOffset);
    
    // 날씨 카드 및 헤더 애니메이션
    const maxScroll = AppConstants.headerHeight;
    
    if (scrollOffset <= maxScroll) {
      // 스크롤 초기 단계: 날씨 카드가 올라감, 헤더가 위로 슬라이드
      final progress = (scrollOffset / maxScroll).clamp(0.0, 1.0);
      setState(() {
        _weatherCardTop = AppConstants.weatherCardInitialTop * (1.0 - progress);
        _headerTop = -AppConstants.headerHeight * progress;
        _headerOpacity = 1.0 - progress;
        _weatherCardPadding = AppConstants.defaultPadding * (1.0 - progress);
        _weatherCardBorderRadius = AppConstants.weatherCardBorderRadius * (1.0 - progress);
      });
    } else {
      // 스크롤이 헤더 높이를 넘으면 날씨 카드 최상단 고정
      if (_weatherCardTop != 0.0 || _headerTop != -AppConstants.headerHeight || 
          _headerOpacity != 0.0 || _weatherCardPadding != 0.0 || 
          _weatherCardBorderRadius != 0.0) {
        setState(() {
          _weatherCardTop = 0.0;
          _headerTop = -AppConstants.headerHeight;
          _headerOpacity = 0.0;
          _weatherCardPadding = 0.0;
          _weatherCardBorderRadius = 0.0;
        });
      }
    }
  }

  void _onNavTap(int index) {
    // 같은 페이지면 무시
    if (index == _currentIndex) return;

    NavigationHelper.handleBottomNavTap(context, index);
  }

  void _onGenderSelected(Gender? gender) {
    // Riverpod Provider에 성별 저장
    ref.read(selectedGenderProvider.notifier).setGender(gender?.name);
    
    print('🏠 [HomePage] 성별 선택: ${gender?.name ?? "전체"}');
    print('✓ [HomePage] 클라이언트 사이드 필터링 수행 (API 호출 안 함)');
    // setState는 자동으로 호출되어 화면 재렌더링됨 (ref.watch가 변경 감지)
    // 이미 로드된 temperatureProductsProvider 데이터를 클라이언트에서 필터링
  }

  // 날씨 모달 열기/닫기
  void _openWeatherModal() {
    // 날씨 페이지로 이동
    Navigator.pushReplacementNamed(context, AppRouter.weather);
  }

  void _closeWeatherModal() {
    setState(() {
      _isWeatherModalOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    
    // 대분류 태그 위치
    final xPosition = AppConstants.defaultPadding;
    final yPosition = screenHeight - AppConstants.categoryTagBottomOffset;
    final contentYPosition = 250.0;
    final sectionSpacing = 30.0;

    // 온도 기반 추천 상품 가져오기
    final temperatureProductsAsync = ref.watch(temperatureProductsProvider);
    final allTemperatureProducts = temperatureProductsAsync.value ?? [];
    final isLoadingProducts = temperatureProductsAsync.isLoading;
    
    // 날씨 정보 가져오기
    final weatherAsync = ref.watch(weatherProvider);
    final weather = weatherAsync.value;
    
    // 성별 선택 관련
    final selectedGenderName = ref.watch(selectedGenderProvider);
    final genders = CategoryData.getGenders();
    
    Gender? selectedGender;
    if (selectedGenderName != null) {
      selectedGender = genders.firstWhere(
        (g) => g.name == selectedGenderName,
        orElse: () => genders.first,
      );
    }
    
    // 성별에 따라 상품 필터링
    List<ClothEntity> filteredProducts;
    if (selectedGenderName == null) {
      // 전체: 남성, 여성 모두
      filteredProducts = allTemperatureProducts;
    } else {
      // 남성 또는 여성만
      filteredProducts = allTemperatureProducts
          .where((product) => product.gender == selectedGenderName)
          .toList();
    }
    
    // 선택된 성별에 따른 대분류 목록
    List<CategoryLarge> largeCategories;
    if (selectedGender != null) {
      largeCategories = selectedGender.larges;
    } else {
      // "전체" 선택 시 - 모든 성별의 대분류를 합쳐서 표시 (중복 제거)
      final allLarges = genders.expand((gender) => gender.larges).toList();
      final Map<String, CategoryLarge> mergedLarges = {};
      
      for (final large in allLarges) {
        if (!mergedLarges.containsKey(large.name)) {
          mergedLarges[large.name] = large;
        }
      }
      largeCategories = mergedLarges.values.toList();
    }
    
    // 대분류별로 상품 그룹화
    final Map<String, List<ClothEntity>> categoryProducts = {};
    for (final large in largeCategories) {
      final products = filteredProducts
          .where((product) => product.largeCategory == large.name)
          .toList();
      if (products.isNotEmpty) {
        categoryProducts[large.id] = products;
      }
    }
    
    // 데이터가 있는 대분류만 필터링
    final largeCategoriesWithData = largeCategories
        .where((large) => categoryProducts.containsKey(large.id))
        .toList();

    // 스크롤 상태에 따라 레이어 순서 결정
    final isScrolled = _weatherCardTop <= 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8), // 배경색 추가
      body: Stack(
        children: [
          // 메인 컨텐츠 - 최하위 레이어
          Column(
            children: [
              // Header 공간 확보
              const SizedBox(height: AppConstants.headerHeight),
              // 메인 컨텐츠 영역 - 스크롤 가능
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(), // 스크롤이 항상 부드럽게 동작
                  child: Column(
                    children: [
                      // 날씨 카드 공간 확보 (날씨 카드 높이 약 100px)
                      const SizedBox(height: 120),
                      
                      // "오늘 날씨에 맞는 옷은?" 텍스트
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 5),
                        child: Text(
                          '오늘 날씨에 맞는 옷은?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF303E51),
                            fontFamily: 'NanumGothicCoding',
                          ),
                        ),
                      ),
                      
                      // 날씨 새로고침 중 메시지 (상품 위에 표시)
                      if (_isRefreshingWeather)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFB4A6E),
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                '의류 정보 업데이트 중...',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFFFB4A6E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      // 대분류별 섹션 리스트 (온도 기반 상품)
                      if (isLoadingProducts)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFFFB4A6E),
                            ),
                          ),
                        )
                      else if (temperatureProductsAsync.hasError)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                const SizedBox(height: 16),
                                Text(
                              '상품 로드 중 오류가 발생했습니다.',
                              style: const TextStyle(color: Colors.red),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  temperatureProductsAsync.error.toString(),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (filteredProducts.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Column(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  selectedGenderName != null 
                                    ? '$selectedGenderName 상품이 없습니다.' 
                                    : '추천 상품이 없습니다.',
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...largeCategoriesWithData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final large = entry.value;
                          final products = categoryProducts[large.id] ?? [];
                          
                          return Column(
                            children: [
                              if (index > 0) SizedBox(height: sectionSpacing), // 섹션 간 간격
                              CategorySection(
                                key: ValueKey('${large.id}_${selectedGender?.name ?? "all"}_${_previousApparentTemp ?? 0}'), // 성별/온도 변경 시 재생성
                                category: large,
                                clothes: products, // 온도 기반으로 필터링된 상품 전달
                                selectedGender: selectedGender,
                                onMoreTap: (largeCategoryName, smallCategoryName) {
                                  // 현재 체감온도 가져오기
                                  final weather = ref.read(weatherProvider).value;
                                  final apparentTemp = weather?.temperatureFeelsLike;
                                  
                                  // 이미 로드된 상품 데이터 전달 (API 호출 안 함)
                                  final allProducts = allTemperatureProducts;
                                  
                                  // 상품 목록 페이지로 이동
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductListPage(
                                        title: '날씨 의류 추천',
                                        initialGender: selectedGender?.name,
                                        initialLargeCategory: largeCategoryName,
                                        initialSmallCategory: smallCategoryName,
                                        apparentTemp: apparentTemp, // 체감온도 전달
                                        initialProducts: allProducts, // 이미 로드된 데이터 전달
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }),
                      
                      // 대분류 태그 하단 여백
                      SizedBox(height: 150),
                      
                      // 하단 여백 - 하단 네비게이션 고려
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Navigation - 스크롤 위치에 따라 애니메이션
          Positioned(
            left: 0,
            right: 0,
            bottom: getNavBottom(scrollOpacity),
            child: Opacity(
              opacity: scrollOpacity,
              child: IgnorePointer(
                ignoring: scrollOpacity < 0.5,
                child: BottomNavigation(
                  currentIndex: _currentIndex,
                  onTap: _onNavTap,
                ),
              ),
            ),
          ),
          // 성별 태그 - 스크롤 위치에 따라 애니메이션
          Positioned(
            left: xPosition,
            top: getTagTop(yPosition, scrollOpacity),
            child: Opacity(
              opacity: scrollOpacity,
              child: IgnorePointer(
                ignoring: scrollOpacity < 0.5,
                child: GenderTagList(
                  genders: CategoryData.getGenders(),
                  selectedGender: selectedGender,
                  onGenderSelected: _onGenderSelected,
                ),
              ),
            ),
          ),
          // 챗봇 버튼 - 화면 오른쪽, 대분류 태그와 같은 y 위치
          Positioned(
            right: 20,
            top: getTagTop(yPosition, scrollOpacity),
            child: Opacity(
              opacity: scrollOpacity,
              child: IgnorePointer(
                ignoring: scrollOpacity < 0.5,
                child: const ChatbotButton(),
              ),
            ),
          ),
          
          // 스크롤 상태에 따라 날씨 카드와 헤더의 레이어 순서 변경
          if (!isScrolled) ...[
            // 스크롤 전: 날씨 카드 먼저 (아래)
            Positioned(
              left: _weatherCardPadding,
              right: _weatherCardPadding,
              top: _weatherCardTop,
              child: WeatherCard(
                weather: weather?.getDisplayWeather() ?? '맑음',
                temperature: weather?.temperatureCurrent.round() ?? 19,
                apparentTemp: weather?.temperatureFeelsLike.round(),
                maxTemp: weather?.temperatureMax.round() ?? 19,
                minTemp: weather?.temperatureMin.round() ?? 19,
                characterImageUrl: AppConstants.characterImages[_currentCharacterIndex],
                skyState: weather?.weatherCondition, // 하늘 상태
                precipitationType: weather?.precipitationType, // 강수 유형 (우선)
                borderRadius: _weatherCardBorderRadius,
                showExpandIcon: _headerOpacity > 0.5, // 헤더가 보일 때만 아이콘 표시
                onTap: _headerOpacity < 0.5 ? _openWeatherModal : null, // 헤더 모드일 때만 카드 전체 클릭 가능
                onExpandIconTap: _openWeatherModal, // 펼치기 아이콘 클릭
                onRefresh: _loadWeather, // 헤더 모드일 때 새로고침 버튼 표시
                fineDust: weather?.dustIndex,
                uvIndex: weather?.uvIndex,
                rainProbability: weather?.precipitationChance,
              ),
            ),
            // 헤더 나중에 (위) - 위로 슬라이드
            Positioned(
              left: 0,
              right: 0,
              top: _headerTop, // 0px -> -93px (위로 슬라이드)
              child: Opacity(
                opacity: _headerOpacity,
                child: IgnorePointer(
                  ignoring: _headerOpacity < 0.5,
                  child: Header(onRefresh: _loadWeather), // 새로고침 콜백 전달
                ),
              ),
            ),
          ] else ...[
            // 스크롤 후: 헤더 먼저 (아래) - 위로 슬라이드된 상태
            Positioned(
              left: 0,
              right: 0,
              top: _headerTop, // -93px (화면 밖)
              child: Opacity(
                opacity: _headerOpacity,
                child: IgnorePointer(
                  ignoring: _headerOpacity < 0.5,
                  child: Header(onRefresh: _loadWeather), // 새로고침 콜백 전달
                ),
              ),
            ),
            // 날씨 카드 나중에 (위)
            Positioned(
              left: _weatherCardPadding,
              right: _weatherCardPadding,
              top: _weatherCardTop,
              child: WeatherCard(
                weather: weather?.getDisplayWeather() ?? '맑음',
                temperature: weather?.temperatureCurrent.round() ?? 19,
                apparentTemp: weather?.temperatureFeelsLike.round(),
                maxTemp: weather?.temperatureMax.round() ?? 19,
                minTemp: weather?.temperatureMin.round() ?? 19,
                characterImageUrl: AppConstants.characterImages[_currentCharacterIndex],
                skyState: weather?.weatherCondition, // 하늘 상태
                precipitationType: weather?.precipitationType, // 강수 유형 (우선)
                borderRadius: _weatherCardBorderRadius,
                showExpandIcon: false, // 스크롤 후에는 아이콘 숨김
                onTap: _openWeatherModal, // 헤더 모드에서는 카드 전체 클릭 가능
                onRefresh: _loadWeather, // 헤더 모드일 때 카드에도 새로고침 표시
                // 스크롤 후에는 미세먼지, 자외선, 강수확률 정보 숨김
                fineDust: null,
                uvIndex: null,
                rainProbability: null,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

