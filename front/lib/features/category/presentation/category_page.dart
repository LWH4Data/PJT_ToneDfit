import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/index.dart';
import '../../../shared/utils/navigation_helper.dart';
import '../../../app/router/app_router.dart';
import '../../cloth/index.dart';
import '../domain/entities/gender.dart';
import '../domain/entities/category_large.dart';
import '../domain/entities/category_small.dart';
import 'widgets/category_large_section.dart';
import 'widgets/category_large_tab.dart';
import 'widgets/gender_tag_list.dart';
import '../../cloth/presentation/pages/product_list_page.dart';

/// 카테고리 검색 페이지
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> with BottomNavScrollMixin {
  int _currentIndex = 2; // 카테고리 탭이 활성화
  CategoryLarge? _selectedLargeCategory; // 선택된 대분류 카테고리
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  final GlobalKey _allSectionKey = GlobalKey(); // "전체" 영역 키
  bool _isScrollingProgrammatically = false; // 프로그래밍 방식 스크롤 중인지 여부

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // 스크롤 위치에 따라 현재 상단에 보이는 중분류 섹션 찾기
  void _onScroll() {
    if (_isScrollingProgrammatically) return; // 프로그래밍 방식 스크롤 중에는 무시
    if (!mounted) return; // 위젯이 마운트되지 않았으면 무시
    
    final scrollOffset = _scrollController.offset;
    
    // 하단 네비게이션 애니메이션 처리 (Mixin 사용)
    handleBottomNavScroll(scrollOffset);
    
    // 화면 상단 기준점 (스크롤 컨텐츠 기준)
    final viewportTop = scrollOffset;
    
    // 성별에 따른 대분류 목록 가져오기 (성별별 캐싱 사용)
    final categoryProductsAsync = ref.read(categoryProductsProvider);
    final genders = CategoryData.getGenders();
    final selectedGenderName = ref.read(selectedGenderProvider);
    
    Gender? selectedGender;
    if (selectedGenderName != null) {
      selectedGender = genders.firstWhere(
        (g) => g.name == selectedGenderName,
        orElse: () => genders.first,
      );
    }
    
    List<CategoryLarge> largeCategories;
    if (selectedGender != null) {
      largeCategories = selectedGender.larges;
    } else {
      final allLarges = genders.expand((gender) => gender.larges).toList();
      final Map<String, CategoryLarge> uniqueLarges = {};
      for (final large in allLarges) {
        if (!uniqueLarges.containsKey(large.name)) {
          uniqueLarges[large.name] = large;
        }
      }
      largeCategories = uniqueLarges.values.toList();
    }
    
    // 해당 성별의 상품 데이터 가져오기 (성별별 캐싱)
    final categoryProducts = categoryProductsAsync.hasValue
        ? ref.read(categoryProductsProvider.notifier).getProductsByGender(
            selectedGenderName,
            largeCategories.map((e) => e.id).toList(),
          )
        : <String, List<ClothEntity>>{};
    
    // 데이터가 있는 대분류만 필터링
    final displayLargeCategories = largeCategories
        .where((large) => categoryProducts.containsKey(large.id) && categoryProducts[large.id]!.isNotEmpty)
        .toList();
    
    // "전체" 영역 위치 계산
    double currentY = 0.0;
    bool isInAllSection = false;
    
    if (_allSectionKey.currentContext != null) {
      final allBox = _allSectionKey.currentContext!.findRenderObject() as RenderBox?;
      if (allBox != null) {
        final allSectionTop = 0.0;
        final allSectionHeight = 20.0; // "전체" 영역 높이
        final allSectionBottom = allSectionTop + allSectionHeight;
        
        // 화면 상단이 "전체" 영역 내에 있는지 확인
        if (viewportTop >= allSectionTop && viewportTop < allSectionBottom) {
          isInAllSection = true;
        }
        
        // 다음 섹션 시작 위치
        currentY = allSectionBottom;
      }
    }
    
    // 각 섹션의 위치 계산
    CategoryLarge? visibleLarge;
    
    if (!isInAllSection) {
      for (int i = 0; i < displayLargeCategories.length; i++) {
        final large = displayLargeCategories[i];
        final key = _sectionKeys[large.id];
        if (key?.currentContext != null) {
          final box = key!.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          final sectionTop = currentY;
          final sectionHeight = box.size.height;
          final sectionBottom = sectionTop + sectionHeight;
          
          // 각 대분류 영역은 다음 섹션과의 30px 간격까지 포함
          final sectionAreaEnd = sectionBottom + 30;
          
          // 화면 상단이 섹션 영역 내에 있는지 확인
          if (viewportTop >= sectionTop && viewportTop < sectionAreaEnd) {
            visibleLarge = large;
            break;
          }
          
          // 다음 섹션의 시작 위치 계산 (간격 30px 포함)
          currentY = sectionBottom + 30;
        }
        }
      }
    }
    
    // 현재 보이는 섹션이 있으면 탭 변경
    if (isInAllSection && _selectedLargeCategory != null) {
      // "전체" 영역에 있으면 "전체"로 변경
      if (mounted) {
        setState(() {
          _selectedLargeCategory = null;
        });
      }
    } else if (visibleLarge != null && _selectedLargeCategory?.id != visibleLarge.id) {
      // 특정 대분류 섹션에 있으면 해당 탭으로 변경
      if (mounted) {
        setState(() {
          _selectedLargeCategory = visibleLarge;
        });
      }
    }
  }

  // 대분류 섹션으로 스크롤
  void _scrollToLargeCategory(CategoryLarge? category) {
    _isScrollingProgrammatically = true; // 프로그래밍 방식 스크롤 시작
    
    if (category == null) {
      // "전체" 선택 시 "전체" 영역으로 스크롤
      if (_allSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _allSectionKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.0, // "전체" 영역이 화면 상단에 위치하도록
        ).then((_) {
          _isScrollingProgrammatically = false; // 스크롤 완료
        });
      } else {
        // 키가 아직 생성되지 않았으면 맨 위로 스크롤
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ).then((_) {
          _isScrollingProgrammatically = false; // 스크롤 완료
        });
      }
      return;
    }

    final key = _sectionKeys[category.id];
    if (key != null && key.currentContext != null) {
      // 해당 섹션의 위치로 스크롤
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0, // 섹션이 화면 상단에 위치하도록
      ).then((_) {
        _isScrollingProgrammatically = false; // 스크롤 완료
      });
    } else {
      _isScrollingProgrammatically = false;
    }
  }

  void _onNavTap(int index) {
    // 같은 페이지면 무시
    if (index == _currentIndex) return;
    NavigationHelper.handleBottomNavTap(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final mediumTabTop = AppConstants.headerHeight + 10; // 헤더 아래 10px 여백
    
    // 성별 태그 위치
    final xPosition = AppConstants.defaultPadding;
    final yPosition = screenHeight - AppConstants.categoryTagBottomOffset;

    // 성별 목록 가져오기
    final genders = CategoryData.getGenders();
    final selectedGenderName = ref.watch(selectedGenderProvider);
    
    // 선택된 성별 찾기
    Gender? selectedGender;
    if (selectedGenderName != null) {
      selectedGender = genders.firstWhere(
        (g) => g.name == selectedGenderName,
        orElse: () => genders.first,
      );
    }

    // Riverpod Provider에서 상품 데이터 가져오기
    final categoryProductsAsync = ref.watch(categoryProductsProvider);

    // 선택된 성별에 따른 대분류 가져오기
    List<CategoryLarge> largeCategories;
    List<CategoryLarge> displayLargeCategories; // 표시할 대분류 목록
    
    if (selectedGender != null) {
      // 특정 성별 선택 시
      largeCategories = selectedGender.larges;
    } else {
      // "전체" 선택 시 - 모든 대분류 가져오기 (중복 제거)
      final allLarges = genders
          .expand((gender) => gender.larges)
          .toList();
      // 같은 이름의 대분류를 하나로 합치기
      final Map<String, CategoryLarge> uniqueLarges = {};
      for (final large in allLarges) {
        if (!uniqueLarges.containsKey(large.name)) {
          uniqueLarges[large.name] = large;
        }
      }
      largeCategories = uniqueLarges.values.toList();
    }
    
    // 해당 성별의 상품 데이터 가져오기 (성별별 캐싱)
    final categoryProducts = categoryProductsAsync.hasValue
        ? ref.read(categoryProductsProvider.notifier).getProductsByGender(
            selectedGenderName,
            largeCategories.map((e) => e.id).toList(),
          )
        : <String, List<ClothEntity>>{};
    
    // 하드코딩된 모든 대분류 표시 (데이터 없어도 표시)
    displayLargeCategories = largeCategories;
    
    // 대분류 탭에서 선택된 대분류가 있으면 해당 대분류만 표시하지 않고
    // 모든 섹션을 보여주되 해당 섹션으로 스크롤 (스크롤 기능을 위해)
    // displayLargeCategories는 그대로 사용

    return Scaffold(
      body: Stack(
        children: [
          // 메인 컨텐츠 - 하단까지 전체 사용
          Positioned(
            left: 0,
            right: 0,
            top: mediumTabTop + 70, // 중분류 탭 아래 70px (전체 영역 포함)
            bottom: 0, // 하단까지 전체 사용 (하단 네비 위에 컨텐츠 표시)
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 스크롤 가능한 영역의 높이 = 화면 높이 - 상단 영역(top)
                // 상단 영역: mediumTabTop + 70
                final scrollableHeight = constraints.maxHeight;
                
                // 무한대나 잘못된 값 체크
                final safeScrollableHeight = scrollableHeight.isFinite && scrollableHeight > 0 
                    ? scrollableHeight 
                    : 0.0;
                
                // 로딩 중일 때는 로딩 인디케이터만 표시
                return categoryProductsAsync.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFB4A6E),
                        ),
                      )
                    : SingleChildScrollView(
                        controller: _scrollController,
                        physics: const ClampingScrollPhysics(), // 스크롤 범위를 정확히 제한
                        padding: const EdgeInsets.only(bottom: 85), // 하단 네비 높이만큼 패딩
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // "전체" 영역 (20px 높이)
                            Container(
                              key: _allSectionKey,
                              height: 20,
                            ),
                            // 대분류 섹션들 나열
                            if (displayLargeCategories.isNotEmpty)
                              ...displayLargeCategories.asMap().entries.map((entry) {
                                final index = entry.key;
                                final large = entry.value;
                                
                                // 각 섹션에 대한 키 생성 및 저장
                                if (!_sectionKeys.containsKey(large.id)) {
                                  _sectionKeys[large.id] = GlobalKey();
                                }
                                
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: index == 0 ? 0 : 30, // 첫 번째 섹션은 여백 없음, 나머지는 간격 30px
                                  ),
                                  child: Container(
                                    key: _sectionKeys[large.id],
                                    child: CategoryLargeSection(
                                      category: large,
                                      selectedGender: selectedGender,
                                      onSmallCategoryTap: (smallCategory) {
                                        // 소분류 카테고리 선택 시 상품 리스트 페이지로 이동
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProductListPage(
                                              title: '${large.name} > ${smallCategory.name}',
                                              initialGender: selectedGender?.name,
                                              initialLargeCategory: large.name,
                                              initialSmallCategory: smallCategory.name,
                                              // apparentTemp는 전달하지 않음 (카테고리 검색에서는 온도 무관)
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }),
                            // 마지막 섹션 다음에 scrollableHeight만큼 빈 공간 추가
                            // 이를 통해 마지막 섹션이 상단에 올 때 최대 스크롤 위치가 됨
                            if (safeScrollableHeight > 0)
                              SizedBox(height: safeScrollableHeight),
                          ],
                        ),
                      );
              },
            ),
          ),
          // 헤더
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Header(showDescription: false), // 카테고리 페이지에서는 설명 숨김
          ),
          // 대분류 카테고리 탭 (입력창 아래) - 로딩 중이 아닐 때만 표시
          if (!categoryProductsAsync.isLoading)
            Positioned(
              left: 0,
              right: 0,
              top: mediumTabTop,
                height: 40,
                child: CategoryLargeTabList(
                  categories: displayLargeCategories,
                  selectedCategory: _selectedLargeCategory,
                  onCategorySelected: (category) {
                  setState(() {
                    _selectedLargeCategory = category;
                  });
                  // 대분류 선택 시 해당 섹션으로 스크롤
                  if (category != null) {
                    // 섹션 키가 생성될 때까지 약간의 지연
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _scrollToLargeCategory(category);
                    });
                  } else {
                    // "전체" 선택 시 맨 위로 즉시 스크롤
                    _scrollToLargeCategory(null);
                  }
                },
              ),
            ),
          // 성별 태그 - 스크롤 위치에 따라 애니메이션 - 로딩 중이 아닐 때만 표시
          if (!categoryProductsAsync.isLoading)
            Positioned(
              left: xPosition,
              top: getTagTop(yPosition, scrollOpacity),
              child: Opacity(
                opacity: scrollOpacity,
                child: IgnorePointer(
                  ignoring: scrollOpacity < 0.5,
                  child: GenderTagList(
                    genders: genders,
                    selectedGender: selectedGender,
                    onGenderSelected: (gender) {
                      // Riverpod Provider에 성별 저장
                      ref.read(selectedGenderProvider.notifier).setGender(gender?.name);
                      
                      setState(() {
                        // 성별 변경 시: 선택된 대분류가 새 성별에 있는지 확인
                        if (_selectedLargeCategory != null) {
                          final newLargeCategories = gender != null 
                              ? gender.larges 
                              : genders.expand((g) => g.larges).toList();
                          
                          // 선택된 대분류가 새 성별에 없으면 null로 초기화 (전체)
                          final exists = newLargeCategories.any(
                            (large) => large.name == _selectedLargeCategory?.name
                          );
                          
                          if (!exists) {
                            print('⚠️ [Category] 대분류 "${_selectedLargeCategory?.name}"가 ${gender?.name ?? "전체"}에 없음 → 전체로 이동');
                            _selectedLargeCategory = null;
                            // 전체 탭 위치로 스크롤
                            Future.delayed(const Duration(milliseconds: 100), () {
                              _scrollToLargeCategory(null);
                            });
                          }
                        }
                      });
                      
                      // 성별 변경 시 상품 데이터 다시 로드 (forceReload)
                      final targetGenders = gender != null ? [gender] : genders;
                      for (final g in targetGenders) {
                        ref.read(categoryProductsProvider.notifier).loadAllCategories(
                          largeCategoryIds: g.larges.map((e) => e.id).toList(),
                          largeCategoryNames: g.larges.map((e) => e.name).toList(),
                          gender: g.name,
                          forceReload: true,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          // Bottom Navigation - 스크롤 위치에 따라 애니메이션
          Positioned(
            left: 0,
            right: 0,
            bottom: getNavBottom(navOpacity),
            child: Opacity(
              opacity: navOpacity,
              child: IgnorePointer(
                ignoring: navOpacity < 0.5, // 반투명일 때 터치 무시
                child: BottomNavigation(
                  currentIndex: _currentIndex,
                  onTap: _onNavTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

