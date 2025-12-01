import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/category_data.dart';
import '../../domain/entities/cloth_entity.dart';
import '../widgets/filter_tag.dart';
import '../widgets/cloth_card.dart';
import '../widgets/price_range_dropdown.dart';
import '../widgets/filters/index.dart';
import '../providers/product_providers.dart';
import 'product_webview_page.dart';
import '../../../search/presentation/widgets/search_input.dart';
import '../../../image_search/presentation/widgets/index.dart';
import '../../../image_search/presentation/providers/image_picker_service.dart';
import '../../../image_search/presentation/pages/image_crop_page.dart';
import '../../../image_search/presentation/pages/image_search_loading_page.dart';
import '../../../../shared/widgets/molecules/bottom_navigation.dart';
import '../../../../shared/mixins/bottom_nav_scroll_mixin.dart';
import '../../../../shared/utils/navigation_helper.dart';
import '../../../../app/router/app_router.dart';

/// 상품 목록 페이지
class ProductListPage extends ConsumerStatefulWidget {
  final String? title;
  final String? initialGender;
  final String? initialLargeCategory; // 대분류 이름
  final String? initialSmallCategory; // 소분류 이름
  final String? initialQuery; // 검색어
  final double? apparentTemp; // 체감온도
  final List<ClothEntity>? initialProducts; // 이미 로드된 상품 목록 (홈에서 전달)
  final Uint8List? imageSearchData; // 이미지 검색 데이터 (이미지 검색 결과에서 전달)

  const ProductListPage({
    super.key,
    this.title,
    this.initialGender,
    this.initialLargeCategory,
    this.initialSmallCategory,
    this.initialQuery,
    this.apparentTemp,
    this.initialProducts,
    this.imageSearchData,
  });

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> with BottomNavScrollMixin {
  // 필터 상태
  String? _selectedPriceRange;
  int? _customMinPrice;
  int? _customMaxPrice;
  String? _selectedColor;
  String? _selectedGender;
  String? _selectedLargeCategory;
  String? _selectedSmallCategory;
  String? _searchQuery; // 검색어
  
  // 필터 모달 상태
  String? _activeFilterModal; // 'gender', 'category', 'color', 'price'
  
  // 상품 목록
  List<ClothEntity> _products = [];
  int _totalCount = 0; // API 응답의 total 값
  bool _isLoading = false;
  
  // 이미지 검색
  final ImagePickerService _imagePickerService = ImagePickerService();
  
  // 이미지 검색 결과용 이미지 접기/펼치기 상태
  bool _isSearchImageExpanded = false;
  
  // 스크롤 컨트롤러
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // 초기값 설정 (이름으로 바로 사용)
    _selectedGender = widget.initialGender;
    _selectedLargeCategory = widget.initialLargeCategory;
    _selectedSmallCategory = widget.initialSmallCategory;
    _searchQuery = widget.initialQuery;
    
    // 스크롤 컨트롤러 초기화
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      handleBottomNavScroll(_scrollController.offset);
    });
    
    // 상품 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialProducts != null) {
        // 홈에서 전달받은 데이터 사용 (API 호출 안 함)
        print('🛍️ [ProductListPage] 전달받은 데이터 사용 (${widget.initialProducts!.length}개)');
        _applyClientSideFiltering();
      } else {
        // 검색이나 다른 경로로 온 경우 API 호출
        print('🛍️ [ProductListPage] API 호출하여 데이터 로드');
        _loadProducts();
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  /// 클라이언트 사이드 필터링 (API 호출 없이)
  void _applyClientSideFiltering() {
    if (widget.initialProducts == null) return;
    
    print('🔍 [ProductListPage] 클라이언트 사이드 필터링 시작...');
    
    var filteredProducts = widget.initialProducts!;
    
    // 성별 필터
    if (_selectedGender != null) {
      filteredProducts = filteredProducts
          .where((p) => p.gender == _selectedGender)
          .toList();
    }
    
    // 대분류 필터
    if (_selectedLargeCategory != null) {
      filteredProducts = filteredProducts
          .where((p) => p.largeCategory == _selectedLargeCategory)
          .toList();
    }
    
    // 소분류 필터
    if (_selectedSmallCategory != null) {
      filteredProducts = filteredProducts
          .where((p) => p.smallCategory == _selectedSmallCategory)
          .toList();
    }
    
    // 색상 필터
    if (_selectedColor != null) {
      filteredProducts = filteredProducts
          .where((p) => p.colors.contains(_selectedColor))
          .toList();
    }
    
    // 가격 필터
    if (_customMinPrice != null || _customMaxPrice != null) {
      filteredProducts = filteredProducts.where((p) {
        if (_customMinPrice != null && p.originalPrice < _customMinPrice!) {
          return false;
        }
        if (_customMaxPrice != null && p.originalPrice > _customMaxPrice!) {
          return false;
        }
        return true;
      }).toList();
    }
    
    setState(() {
      _products = filteredProducts;
      _totalCount = filteredProducts.length;
    });
    
    print('✅ [ProductListPage] 필터링 완료: ${_products.length}개');
  }
  
  /// 검색 모드 AppBar 생성
  PreferredSizeWidget _buildSearchAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(93), // 검색 페이지와 동일한 높이
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 53, // 상태바 + 여백
        ),
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              // 뒤로가기 아이콘 (왼쪽 고정)
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Color(0xFF292D32),
                ),
              ),
              const SizedBox(width: 12),
              // 입력창 (반응형, 남은 공간 채우기)
              Expanded(
                child: SearchInput(
                  margin: EdgeInsets.zero,
                  autoFocus: false,
                  initialValue: _searchQuery,
                  onSubmitted: (query) {
                    if (query.isNotEmpty) {
                      setState(() {
                        _searchQuery = query;
                      });
                      _loadProducts();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // 이미지 검색 아이콘 (오른쪽 고정)
              GestureDetector(
                onTap: () {
                  _showImageSearchModal();
                },
                child: const Icon(
                  Icons.image_search_rounded,
                  size: 25,
                  color: Color(0xFF292D32),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 이미지 검색 모달 표시
  void _showImageSearchModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ImageSearchModal(
            onGalleryTap: () async {
              Navigator.pop(context);
              await _pickImageFromGallery();
            },
            onCameraTap: () async {
              Navigator.pop(context);
              await _pickImageFromCamera();
            },
            onCancel: () {
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }
  
  /// 갤러리에서 이미지 선택
  Future<void> _pickImageFromGallery() async {
    try {
      final File? imageFile = await _imagePickerService.pickFromGallery();
      
      if (imageFile != null && mounted) {
        await _navigateToImageCrop(imageFile);
      } else if (mounted) {
        _showImageSearchModal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 선택 실패'), duration: Duration(seconds: 2)),
        );
      }
    }
  }
  
  /// 카메라로 사진 촬영
  Future<void> _pickImageFromCamera() async {
    try {
      final File? imageFile = await _imagePickerService.pickFromCamera();
      
      if (imageFile != null && mounted) {
        await _navigateToImageCrop(imageFile);
      } else if (mounted) {
        _showImageSearchModal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 촬영 실패'), duration: Duration(seconds: 2)),
        );
      }
    }
  }
  
  /// 이미지 크롭 페이지로 이동
  Future<void> _navigateToImageCrop(File imageFile) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => ImageCropPage(imageFile: imageFile)),
    );
    
    if (result != null && mounted) {
      final croppedBytes = result['bytes'] as Uint8List;
      _navigateToImageSearchLoading(croppedBytes);
    } else if (mounted) {
      _showImageSearchModal();
    }
  }
  
  /// 이미지 검색 로딩 페이지로 이동
  Future<void> _navigateToImageSearchLoading(Uint8List imageData) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => ImageSearchLoadingPage(imageData: imageData)),
    );
    
    if (result == 'reselect' && mounted) {
      _showImageSearchModal();
    }
  }
  
  /// 하단 네비게이션 탭 처리
  void _onNavTap(int index) {
    // 공통 네비게이션 헬퍼 사용
    NavigationHelper.handleBottomNavTap(context, index);
  }
  
  /// 상품 목록 로드
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ref.read(clothApiServiceProvider);
      
      // 첫 페이지 호출
      final firstResponse = await apiService.filterProducts(
        apparentTemp: widget.apparentTemp, // 체감온도 전달
        query: _searchQuery, // 검색어
        gender: _selectedGender,
        largeCategory: _selectedLargeCategory, // 이미 이름으로 저장됨
        smallCategory: _selectedSmallCategory, // 이미 이름으로 저장됨
        minPrice: _customMinPrice,
        maxPrice: _customMaxPrice,
        colors: _selectedColor != null ? [_selectedColor!] : null,
        page: 1,
        pageSize: 100,
      );
      
      final allProducts = <ClothEntity>[...firstResponse.products];
      print('🛍️ [ProductListPage] 첫 페이지 로드: ${firstResponse.products.length}/${firstResponse.total}개');
      
      // total이 100개보다 많으면 추가 페이지 호출
      if (firstResponse.total > 100) {
        final totalPages = (firstResponse.total / 100).ceil();
        print('📄 [ProductListPage] 추가 페이지 로드 필요: ${totalPages}페이지');
        
        for (int pageNum = 2; pageNum <= totalPages; pageNum++) {
          final pageResponse = await apiService.filterProducts(
            apparentTemp: widget.apparentTemp,
            query: _searchQuery,
            gender: _selectedGender,
            largeCategory: _selectedLargeCategory,
            smallCategory: _selectedSmallCategory,
            minPrice: _customMinPrice,
            maxPrice: _customMaxPrice,
            colors: _selectedColor != null ? [_selectedColor!] : null,
            page: pageNum,
            pageSize: 100,
          );
          
          allProducts.addAll(pageResponse.products);
          print('✓ [ProductListPage] 페이지 $pageNum: ${pageResponse.products.length}개 추가');
        }
      }
      
      setState(() {
        _products = allProducts;
        _totalCount = firstResponse.total; // API 응답의 total 저장
        _isLoading = false;
      });
      
      print('✅ [ProductListPage] 상품 로드 완료: ${_products.length}개 (전체: ${_totalCount}개)');
      print('  - 체감온도: ${widget.apparentTemp}°C');
      print('  - 성별: ${_selectedGender ?? "전체"}');
      print('  - 대분류: ${_selectedLargeCategory ?? "전체"}');
      print('  - 소분류: ${_selectedSmallCategory ?? "전체"}');
    } catch (e) {
      print('❌ [ProductListPage] 상품 로드 실패: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final genders = CategoryData.getGenders();

    return Scaffold(
      appBar: _searchQuery != null 
        ? _buildSearchAppBar() // 검색 모드: 검색창이 있는 헤더
        : AppBar( // 일반 모드: 기본 헤더
        title: Text(widget.title ?? '상품 목록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
            surfaceTintColor: Colors.white, // Material 3에서도 하얀색 유지
            scrolledUnderElevation: 0, // 스크롤 시에도 그림자 없음
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
        children: [
          // 이미지 검색 결과용 이미지 표시 (접기/펼치기 가능)
          if (widget.imageSearchData != null)
            _buildSearchImageSection(),
          
          // 필터 영역 (가로 나열, 스크롤 가능)
          Container(
            height: 50,
            width: double.infinity,
              color: Colors.white,
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // 필터 아이콘
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: const Color(0xFF292D32),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '필터',
                          style: TextStyle(
                            color: const Color(0xFF292D32),
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            height: 1.71,
                            letterSpacing: 0.40,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 성별 드롭다운
                  _buildInlineDropdown('성별', 'gender', () {
                    setState(() {
                      _activeFilterModal = _activeFilterModal == 'gender' ? null : 'gender';
                    });
                  }),
                  // 카테고리 드롭다운
                  _buildInlineDropdown('카테고리', 'category', () {
                    setState(() {
                      _activeFilterModal = _activeFilterModal == 'category' ? null : 'category';
                    });
                  }),
                  // 컬러 드롭다운
                  _buildInlineDropdown('컬러', 'color', () {
                    setState(() {
                      _activeFilterModal = _activeFilterModal == 'color' ? null : 'color';
                    });
                  }),
                  // 가격 드롭다운
                  _buildInlineDropdown('가격', 'price', () {
                    setState(() {
                      _activeFilterModal = _activeFilterModal == 'price' ? null : 'price';
                    });
                  }),
                ],
              ),
            ),
          ),
          // 선택된 필터 태그 영역
          if (_hasActiveFilters())
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: Colors.white,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildFilterTags(),
              ),
            ),
          // 상품 목록 영역 (상품 개수 + 그리드)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFB4A6E)))
                : _products.isEmpty
                    ? const Center(
                        child: Text(
                          '상품이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // 화면 너비에 따라 열 개수 결정
                          final screenWidth = constraints.maxWidth;
                          int crossAxisCount = 2; // 기본 2열
                          
                          if (screenWidth >= 900) {
                            crossAxisCount = 4; // 큰 화면은 4열
                          } else if (screenWidth >= 600) {
                            crossAxisCount = 3; // 중간 화면은 3열
                          }
                          
                          // 패딩과 간격을 제외한 카드 너비 계산
                          const horizontalPadding = 10.0;
                          const cardSpacing = 8.0;
                          final totalPadding = horizontalPadding * 2;
                          final totalSpacing = cardSpacing * (crossAxisCount - 1);
                          final cardWidth = (screenWidth - totalPadding - totalSpacing) / crossAxisCount;
                          
                          // 카드 비율 유지하여 높이 계산 (2:1 비율)
                          final cardHeight = cardWidth * 2.0;
                          
                          return CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              // 상품 개수 표시
                              SliverToBoxAdapter(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.only(left: 20, top: 12, bottom: 12),
                                  child: Text(
                                    '총 ${_totalCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}개',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF9AA6B2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // 상품 그리드
                              SliverPadding(
                                padding: const EdgeInsets.all(10),
                                sliver: SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: 12,
                              crossAxisSpacing: cardSpacing,
                              childAspectRatio: cardWidth / cardHeight,
                            ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                              final cloth = _products[index];
                              return ClothCard(
                                key: ValueKey('${cloth.productId}_${_selectedGender ?? "all"}_${_selectedLargeCategory ?? "all"}_${_selectedSmallCategory ?? "all"}_${_selectedColor ?? "all"}_${_selectedPriceRange ?? "all"}'), // 필터 변경 시 재생성
                                productId: cloth.productId,
                                name: cloth.name,
                                brand: cloth.brand,
                                        productUrl: cloth.productUrl,
                                representativeImageUrl: cloth.representativeImageUrl,
                                originalPrice: cloth.originalPrice,
                                colors: cloth.colors,
                                smallCategoryName: cloth.smallCategory,
                                        width: cardWidth,
                                        height: cardHeight,
                                onTap: () {
                                          // WebView로 상품 페이지 열기
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductWebViewPage(
                                                url: cloth.productUrl,
                                                title: cloth.name,
                                              ),
                                            ),
                                          );
                                        },
                              );
                            },
                                    childCount: _products.length,
                                  ),
                                ),
                              ),
                              // 하단 네비게이션 여백
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 80), // 네비게이션 높이만큼 여백
                              ),
                            ],
                          );
                        },
                      ),
          ),
            ],
          ),
          // 필터 모달 (필터 탭 바로 아래 표시)
          if (_activeFilterModal != null)
            Positioned(
              top: 50, // 필터 바 높이
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() => _activeFilterModal = null);
                },
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: GestureDetector(
                    onTap: () {}, // 모달 내부 클릭 시 닫히지 않도록
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: _buildFilterModalContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // 하단 네비게이션
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: getNavBottom(scrollOpacity),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: scrollOpacity,
              child: BottomNavigation(
                currentIndex: -1, // 현재 페이지는 네비게이션 항목이 아님
                onTap: _onNavTap,
              ),
                      ),
          ),
        ],
      ),
    );
  }

  /// 필터 모달 컨텐츠 빌드
  Widget _buildFilterModalContent() {
    final filterTagsData = _buildFilterTagsData(); // 태그 데이터만 생성
    
    switch (_activeFilterModal) {
      case 'gender':
        return GenderFilterModal(
          selectedGender: _selectedGender,
          onGenderChanged: (value) {
            setState(() {
              _selectedGender = value;
              _selectedLargeCategory = null;
              _selectedSmallCategory = null;
            });
          },
          onApply: _applyFilter,
          onCancel: _cancelFilter,
          filterTags: filterTagsData,
          onRemoveTag: _handleRemoveTag,
        );
      case 'category':
        return CategoryFilterModal(
          selectedGender: _selectedGender,
          selectedLargeName: _selectedLargeCategory,
          selectedSmallName: _selectedSmallCategory,
          onLargeChanged: (value) {
            setState(() {
              _selectedLargeCategory = value;
              _selectedSmallCategory = null;
            });
          },
          onSmallChanged: (value) {
            setState(() {
              _selectedSmallCategory = value;
            });
          },
          onApply: _applyFilter,
          onCancel: _cancelFilter,
          filterTags: filterTagsData,
          onRemoveTag: _handleRemoveTag,
        );
      case 'color':
        return ColorFilterModal(
          selectedColor: _selectedColor,
          onColorChanged: (value) {
            setState(() {
              _selectedColor = value;
            });
          },
          onApply: _applyFilter,
          onCancel: _cancelFilter,
          filterTags: filterTagsData,
          onRemoveTag: _handleRemoveTag,
        );
      case 'price':
        return PriceFilterModal(
          selectedPriceRange: _selectedPriceRange,
          onPriceRangeChanged: (value) {
            setState(() {
              _selectedPriceRange = value;
            });
          },
          onCustomPriceChanged: (priceRange) {
            setState(() {
              _customMinPrice = priceRange?['min'];
              _customMaxPrice = priceRange?['max'];
            });
          },
          onApply: _applyFilter,
          onCancel: _cancelFilter,
          filterTags: filterTagsData,
          onRemoveTag: _handleRemoveTag,
        );
      default:
        return const SizedBox.shrink();
    }
  }
  
  /// 태그 제거 처리
  void _handleRemoveTag(String type) {
    setState(() {
      switch (type) {
        case 'gender':
          _selectedGender = null;
          _selectedLargeCategory = null;
          _selectedSmallCategory = null;
          break;
        case 'category':
          _selectedLargeCategory = null;
          _selectedSmallCategory = null;
          break;
        case 'color':
          _selectedColor = null;
          break;
        case 'price':
          _selectedPriceRange = null;
          _customMinPrice = null;
          _customMaxPrice = null;
          break;
      }
    });
    
    if (widget.initialProducts != null) {
      // 홈에서 온 경우: 클라이언트 사이드 필터링만
      _applyClientSideFiltering();
    } else {
      // 검색이나 다른 경로로 온 경우: API 호출
      _loadProducts();
    }
  }
  
  /// 필터 태그 데이터 생성 (가벼운 데이터만)
  List<FilterTagData> _buildFilterTagsData() {
    final tags = <FilterTagData>[];
    final genders = CategoryData.getGenders();

    // 성별 태그
    if (_selectedGender != null) {
      tags.add(FilterTagData(
        label: _selectedGender!,
        type: 'gender',
      ));
    }

    // 카테고리 태그
    if (_selectedLargeCategory != null || _selectedSmallCategory != null) {
      String categoryLabel;
      if (_selectedLargeCategory != null && _selectedSmallCategory != null) {
        // 대분류 + 소분류
        categoryLabel = '$_selectedLargeCategory > $_selectedSmallCategory';
      } else if (_selectedLargeCategory != null) {
        // 대분류만
        categoryLabel = '$_selectedLargeCategory > 전체';
      } else {
        // 소분류만 (대분류 전체)
        categoryLabel = '전체 > $_selectedSmallCategory';
      }
      
      tags.add(FilterTagData(
        label: categoryLabel,
        type: 'category',
      ));
    }

    // 색상 태그
    if (_selectedColor != null) {
      tags.add(FilterTagData(
        label: _selectedColor!,
        type: 'color',
      ));
    }

    // 가격 태그
    if (_selectedPriceRange != null) {
      String priceLabel;
      if (_selectedPriceRange == 'custom' && _customMinPrice != null) {
        // 직접 입력: "10,000원 ~ 30,000원" 형식
        final minText = '${_customMinPrice!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
        final maxText = _customMaxPrice != null 
          ? '${_customMaxPrice!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원' 
          : '이상';
        priceLabel = _customMaxPrice != null ? '$minText ~ $maxText' : '$minText $maxText';
      } else {
        final range = PriceRangeDropdown.priceRanges.firstWhere(
          (r) => r['value'] == _selectedPriceRange,
          orElse: () => PriceRangeDropdown.priceRanges[0],
        );
        priceLabel = range['label'];
      }
      
      tags.add(FilterTagData(
        label: priceLabel,
        type: 'price',
      ));
    }

    return tags;
  }
  
  /// 필터 적용 및 모달 닫기
  void _applyFilter() {
    setState(() => _activeFilterModal = null);
    
    if (widget.initialProducts != null) {
      // 홈에서 온 경우: 클라이언트 사이드 필터링만
      _applyClientSideFiltering();
    } else {
      // 검색이나 다른 경로로 온 경우: API 호출
      _loadProducts();
    }
  }
  
  /// 필터 취소 및 모달 닫기
  void _cancelFilter() {
    setState(() => _activeFilterModal = null);
  }

  bool _hasActiveFilters() {
    return _selectedGender != null ||
           _selectedLargeCategory != null ||
           _selectedSmallCategory != null ||
           _selectedColor != null ||
           _selectedPriceRange != null;
  }

  List<Widget> _buildFilterTags() {
    final tags = <Widget>[];
    final genders = CategoryData.getGenders();

    // 성별 태그
    if (_selectedGender != null) {
      tags.add(FilterTag(
        label: _selectedGender!,
        onRemove: () {
          setState(() {
            _selectedGender = null;
            _selectedLargeCategory = null;
            _selectedSmallCategory = null;
          });
          
          if (widget.initialProducts != null) {
            _applyClientSideFiltering();
          } else {
            _loadProducts();
          }
        },
      ));
    }

    // 카테고리 태그 (대분류 > 소분류)
    if (_selectedLargeCategory != null || _selectedSmallCategory != null) {
      String categoryLabel;
      
      if (_selectedLargeCategory != null && _selectedSmallCategory != null) {
        // 대분류 + 소분류
        categoryLabel = '$_selectedLargeCategory > $_selectedSmallCategory';
      } else if (_selectedLargeCategory != null) {
        // 대분류만
        categoryLabel = '$_selectedLargeCategory > 전체';
      } else {
        // 소분류만 (대분류 전체)
        categoryLabel = '전체 > $_selectedSmallCategory';
      }
      
      tags.add(FilterTag(
        label: categoryLabel,
        onRemove: () {
          setState(() {
            _selectedLargeCategory = null;
            _selectedSmallCategory = null;
          });
          
          if (widget.initialProducts != null) {
            _applyClientSideFiltering();
          } else {
            _loadProducts();
          }
        },
      ));
    }

    // 색상 태그
    if (_selectedColor != null) {
      tags.add(FilterTag(
        label: _selectedColor!,
        onRemove: () {
          setState(() {
            _selectedColor = null;
          });
          
          if (widget.initialProducts != null) {
            _applyClientSideFiltering();
          } else {
            _loadProducts();
          }
        },
      ));
    }

    // 가격 태그
    if (_selectedPriceRange != null) {
      String priceLabel;
      if (_selectedPriceRange == 'custom' && _customMinPrice != null) {
        // 직접 입력: "10,000원 ~ 30,000원" 형식
        final minText = '${_customMinPrice!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
        final maxText = _customMaxPrice != null 
          ? '${_customMaxPrice!.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원' 
          : '이상';
        priceLabel = _customMaxPrice != null ? '$minText ~ $maxText' : '$minText $maxText';
      } else {
        final range = PriceRangeDropdown.priceRanges.firstWhere(
          (r) => r['value'] == _selectedPriceRange,
          orElse: () => PriceRangeDropdown.priceRanges[0],
        );
        priceLabel = range['label'];
      }
      
      tags.add(FilterTag(
        label: priceLabel,
        onRemove: () {
          setState(() {
            _selectedPriceRange = null;
            _customMinPrice = null;
            _customMaxPrice = null;
          });
          
          if (widget.initialProducts != null) {
            _applyClientSideFiltering();
          } else {
            _loadProducts();
          }
        },
      ));
    }

    return tags;
  }

  Widget _buildInlineDropdown(String label, String filterKey, VoidCallback onTap) {
    final isActive = _activeFilterModal == filterKey;
    final color = isActive ? const Color(0xFF476A62) : Colors.black.withValues(alpha: 0.60);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF476A62).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                height: 1.71,
                letterSpacing: 0.40,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isActive ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
  
  /// 이미지 검색 결과용 이미지 섹션 (접기/펼치기)
  Widget _buildSearchImageSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = _isSearchImageExpanded ? 200.0 : 80.0;
    final imageWidth = _isSearchImageExpanded ? screenWidth * 0.6 : 60.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: screenWidth,
      height: imageHeight,
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 이미지
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: imageWidth,
              height: imageHeight - 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.black,
                  child: Image.memory(
                    widget.imageSearchData!,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          // 확대/축소 아이콘 (이미지 오른쪽 하단)
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchImageExpanded = !_isSearchImageExpanded;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                  child: Icon(
                    _isSearchImageExpanded 
                        ? Icons.zoom_in_map    // 확대된 상태 → 더 축소하기 (안으로)
                        : Icons.zoom_out_map,  // 축소된 상태 → 더 확대하기 (밖으로)
                    color: Colors.white,
                    size: 20,
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

