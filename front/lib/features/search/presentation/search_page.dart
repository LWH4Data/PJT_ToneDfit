import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../index.dart';
import '../providers/recent_search_provider.dart';
import '../providers/trending_search_provider.dart';
import '../../../shared/index.dart';
import '../../../shared/utils/navigation_helper.dart';
import '../../../app/router/app_router.dart';
import '../../cloth/index.dart';
import '../../cloth/presentation/pages/product_list_page.dart';
import '../../category/domain/entities/gender.dart';
import '../../category/presentation/widgets/gender_tag_list.dart';
import '../../image_search/presentation/widgets/index.dart';
import '../../image_search/presentation/providers/image_picker_service.dart';
import '../../image_search/presentation/pages/image_crop_page.dart';
import '../../image_search/presentation/pages/image_search_loading_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> with BottomNavScrollMixin {
  final int _currentIndex = -1; // 검색 페이지는 하단 네비에 없으므로 -1 (비활성화)
  final ScrollController _scrollController = ScrollController();
  final ImagePickerService _imagePickerService = ImagePickerService();
  Timer? _trendingRefreshTimer; // 인기 검색어 자동 새로고침 타이머

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // 자동 새로고침 타이머만 시작 (초기 로드 제거)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTrendingRefreshTimer();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _trendingRefreshTimer?.cancel(); // 타이머 정리
    super.dispose();
  }
  
  /// 인기 검색어 자동 새로고침 타이머 시작 (1시간마다 정각)
  void _startTrendingRefreshTimer() {
    final now = DateTime.now();
    
    // 다음 정각까지 남은 시간 계산
    final nextHour = DateTime(now.year, now.month, now.day, now.hour + 1, 0, 0);
    final durationUntilNextHour = nextHour.difference(now);
    
    print('🕐 [SearchPage] 다음 정각까지: ${durationUntilNextHour.inMinutes}분 ${durationUntilNextHour.inSeconds % 60}초');
    
    // 다음 정각에 첫 호출
    Future.delayed(durationUntilNextHour, () {
      if (mounted) {
        print('⏰ [SearchPage] 정각 도달 - 인기 검색어 자동 새로고침');
        ref.read(trendingSearchProvider.notifier).loadTrendingKeywords();
        
        // 이후로는 1시간마다 반복
        _trendingRefreshTimer = Timer.periodic(const Duration(hours: 1), (timer) {
          if (mounted) {
            print('⏰ [SearchPage] 1시간 경과 - 인기 검색어 자동 새로고침');
            ref.read(trendingSearchProvider.notifier).loadTrendingKeywords();
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  void _onScroll() {
    // 하단 네비게이션 애니메이션 처리 (Mixin 사용)
    handleBottomNavScroll(_scrollController.position.pixels);
  }

  void _onNavTap(int index) {
    NavigationHelper.handleBottomNavTap(context, index);
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
        // 이미지 크롭 페이지로 이동
        await _navigateToImageCrop(imageFile);
      } else if (mounted) {
        // 이미지 선택 취소 시 모달 다시 표시
        _showImageSearchModal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미지 선택 실패'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  /// 카메라로 사진 촬영
  Future<void> _pickImageFromCamera() async {
    try {
      final File? imageFile = await _imagePickerService.pickFromCamera();
      
      if (imageFile != null && mounted) {
        // 이미지 크롭 페이지로 이동
        await _navigateToImageCrop(imageFile);
      } else if (mounted) {
        // 사진 촬영 취소 시 모달 다시 표시
        _showImageSearchModal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('사진 촬영 실패'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  
  /// 이미지 크롭 페이지로 이동
  Future<void> _navigateToImageCrop(File imageFile) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropPage(imageFile: imageFile),
      ),
    );
    
    if (result != null && mounted) {
      final croppedFile = result['file'] as File;
      final croppedBytes = result['bytes'] as Uint8List;
      
      // 이미지 검색 로딩 페이지로 이동
      _navigateToImageSearchLoading(croppedBytes);
    } else if (mounted) {
      // 크롭 취소 시 모달 다시 표시
      _showImageSearchModal();
    }
  }
  
  /// 이미지 검색 로딩 페이지로 이동
  Future<void> _navigateToImageSearchLoading(Uint8List imageData) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageSearchLoadingPage(imageData: imageData),
      ),
    );
    
    // 이미지 다시 선택 요청 시 모달 다시 표시
    if (result == 'reselect' && mounted) {
      _showImageSearchModal();
    }
  }
  
  /// 검색 결과 페이지로 이동
  void _navigateToSearchResults(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListPage(
          title: query, // 검색어를 타이틀로 표시
          initialQuery: query, // 검색어 전달
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    
    // 위치 및 크기
    final top = 53.0;
    
    // 대분류 태그 위치 (홈/카테고리와 동일)
    final xPosition = (screenWidth - 160.0) / 2; // 가운데 정렬 (태그 너비 160px)
    final yPosition = screenHeight - 145.0; // 하단 네비게이션 높이(85px) + 60px 차이
    
    // Riverpod Provider에서 선택된 성별 가져오기
    final selectedGenderName = ref.watch(selectedGenderProvider);
    final genders = CategoryData.getGenders();
    
    Gender? selectedGender;
    if (selectedGenderName != null) {
      selectedGender = genders.firstWhere(
        (g) => g.name == selectedGenderName,
        orElse: () => genders.first,
      );
    }

    return GestureDetector(
      onTap: () {
        // 화면 터치 시 키보드 닫기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            // 스크롤 가능한 메인 컨텐츠
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 85), // 하단 네비 높이만큼 패딩
                child: Builder(
                  builder: (context) {
                    final recentSearchAsync = ref.watch(recentSearchProvider);
                    final recentItems = recentSearchAsync.hasValue ? recentSearchAsync.value! : <String>[];
                    final hasRecentSearches = recentItems.isNotEmpty;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: top + 60), // 입력창 영역만큼 상단 여백
                        
                        // 최근 검색어 섹션
                        if (hasRecentSearches) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      '최근 검색어',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        ref.read(recentSearchProvider.notifier).clear();
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(40, 24),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        '전체 삭제',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9AA6B2),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 32,
                                  child: RecentSearchTagList(
                                    items: recentItems,
                                    onTapItem: (query) {
                                      // 최근 검색어 클릭 시 검색 실행
                                      _navigateToSearchResults(query);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        
                        // 인기 검색어 섹션
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Consumer(
                            builder: (context, ref, child) {
                              final trendingState = ref.watch(trendingSearchProvider);
                              
                              return PopularSearchSection(
                                items: trendingState.items,
                                lastUpdated: trendingState.timestamp,
                                onItemTap: (keyword) {
                                  // 인기 검색어 클릭 시 검색 실행
                                  ref.read(recentSearchProvider.notifier).add(keyword);
                                  _navigateToSearchResults(keyword);
                                },
                                onRefresh: () {
                                  // 새로고침 버튼 클릭 시 인기 검색어 재로드
                                  ref.read(trendingSearchProvider.notifier).loadTrendingKeywords();
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // 입력창 영역
            Positioned(
              left: 0,
              right: 0,
              top: top,
              height: 40.0,
              child: Row(
                children: [
                  // 뒤로가기 아이콘 (왼쪽 고정)
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                      autoFocus: true,
                      onSubmitted: (query) {
                        if (query.isNotEmpty) {
                          // 최근 검색어에 추가
                          ref.read(recentSearchProvider.notifier).add(query);
                          // 검색 결과 페이지로 이동
                          _navigateToSearchResults(query);
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
          // Bottom Navigation - 스크롤 위치에 따라 애니메이션
          Positioned(
            left: 0,
            right: 0,
            bottom: getNavBottom(navOpacity),
            child: Opacity(
              opacity: navOpacity,
              child: IgnorePointer(
                ignoring: navOpacity < 0.5,
                child: BottomNavigation(
                  currentIndex: _currentIndex,
                  onTap: _onNavTap,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}


