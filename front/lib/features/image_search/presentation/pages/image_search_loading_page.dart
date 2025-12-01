import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../cloth/domain/entities/cloth_entity.dart';
import '../../../cloth/presentation/widgets/cloth_card.dart';
import '../../../cloth/presentation/pages/product_webview_page.dart';
import '../../../cloth/presentation/pages/product_list_page.dart';
import '../../../../shared/widgets/loading_dots.dart';
import '../../data/remote/image_search_api_service.dart';

/// 이미지 검색 로딩 및 결과 페이지
class ImageSearchLoadingPage extends StatefulWidget {
  final Uint8List imageData;

  const ImageSearchLoadingPage({
    super.key,
    required this.imageData,
  });

  @override
  State<ImageSearchLoadingPage> createState() => _ImageSearchLoadingPageState();
}

class _ImageSearchLoadingPageState extends State<ImageSearchLoadingPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<ClothEntity> _searchResults = [];
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  final ImageSearchApiService _apiService = ImageSearchApiService();
  bool _isImageExpanded = true; // 이미지 펼침/접힘 상태

  @override
  void initState() {
    super.initState();
    
    // 스캔 애니메이션 초기화 (위→아래로 반복)
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
    
    // 이미지 검색 API 호출
    _searchImageProducts();
  }
  
  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }
  
  /// 이미지 검색 API 호출
  Future<void> _searchImageProducts() async {
    try {
      // 실제 API 호출 (POST /ai/search/image)
      final results = await _apiService.searchByImage(widget.imageData);
      
      if (mounted) {
        // 스캔 애니메이션 중지
        _scanController.stop();
        
        // 결과가 있으면 ProductListPage로 이동 (필터 기능 사용)
        if (results.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProductListPage(
                title: '이미지 검색 결과',
                initialProducts: results,
                imageSearchData: widget.imageData, // 검색한 이미지 전달
              ),
            ),
          );
        } else {
          // 결과가 없으면 현재 페이지에 표시
          setState(() {
            _isLoading = false;
            _searchResults = results;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // 스캔 애니메이션 중지
        _scanController.stop();
        
        setState(() {
          _isLoading = false;
        });
        
        // 에러 메시지 처리
        String errorMessage = '이미지 검색 실패: $e';
        Color backgroundColor = Colors.red;
        
        if (e.toString().contains('index is not available') || 
            e.toString().contains('503')) {
          errorMessage = '이미지 검색 기능은 현재 구현 중입니다.\n빠른 시일 내에 만나보실 수 있습니다! 😊';
          backgroundColor = const Color(0xFFFB4A6E); // 브랜드 컬러
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 93.0; // 공통 헤더 높이
    
    // 이미지 영역 높이 (펼침/접힌 상태에 따라)
    final imageAreaHeight = _isImageExpanded ? 549.0 : 120.0;
    final imageContainerWidth = _isImageExpanded ? 252.0 : 80.0;
    final imageContainerHeight = _isImageExpanded ? 526.0 : 100.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F8),
      appBar: AppBar(
        title: const Text('이미지 검색'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 상단 이미지 영역 (흰색 배경) - 애니메이션 적용
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            top: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: screenWidth,
              height: imageAreaHeight,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // 이미지
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: imageContainerWidth,
                      height: imageContainerHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            // 이미지 (가로 세로 비율 유지하며 최대한 크게 표시)
                            Container(
                              width: imageContainerWidth,
                              height: imageContainerHeight,
                              color: Colors.black, // 여백 영역 배경색
                              child: Image.memory(
                                widget.imageData,
                                fit: BoxFit.contain, // cover → contain (잘리지 않게)
                              ),
                            ),
                            // 스캔 애니메이션 (로딩 중일 때만, 펼쳐진 상태에서만)
                            if (_isLoading && _isImageExpanded)
                              AnimatedBuilder(
                                animation: _scanAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    left: 0,
                                    right: 0,
                                    top: _scanAnimation.value * imageContainerHeight,
                                    child: Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            const Color(0xFFFB4A6E).withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFB4A6E).withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 접기/펼치기 아이콘 (로딩 완료 후에만 표시)
                  if (!_isLoading)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isImageExpanded = !_isImageExpanded;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isImageExpanded 
                                  ? Icons.keyboard_arrow_up 
                                  : Icons.keyboard_arrow_down,
                              color: const Color(0xFFFB4A6E),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 하단 영역 (로딩 또는 검색 결과) - 이미지 높이에 따라 위치 변경
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            top: imageAreaHeight,
            child: Container(
              width: screenWidth,
              height: screenHeight - imageAreaHeight - kToolbarHeight - MediaQuery.of(context).padding.top,
              color: const Color(0xFFF3F5F8),
              child: _isLoading
                  ? _buildLoadingWidget()
                  : _buildSearchResults(screenWidth),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 로딩 위젯
  Widget _buildLoadingWidget() {
    return LoadingDots(
      message: '이미지 검색 중',
      icon: Container(
        width: 45,
        height: 68,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.search,
          size: 32,
          color: Color(0xFF476A62),
        ),
      ),
    );
  }
  
  /// 검색 결과 표시 (product_list_page 스타일)
  Widget _buildSearchResults(double screenWidth) {
    // product_list_page와 동일한 그리드 설정
    const horizontalPadding = 16.0;
    const cardSpacing = 12.0;
    const totalPadding = horizontalPadding * 2;
    const totalSpacing = cardSpacing;
    final cardWidth = (screenWidth - totalPadding - totalSpacing) / 2;
    final cardHeight = cardWidth * 2; // 2:1 비율
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(horizontalPadding),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.5,
          mainAxisSpacing: cardSpacing,
          crossAxisSpacing: cardSpacing,
        ),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final product = _searchResults[index];
          return ClothCard(
            productId: product.productId,
            name: product.name,
            brand: product.brand,
            productUrl: product.productUrl ?? '',
            representativeImageUrl: product.representativeImageUrl ?? '',
            originalPrice: product.originalPrice,
            colors: product.colors,
            smallCategoryName: product.smallCategory,
            width: cardWidth,
            height: cardHeight,
            onTap: () {
              if (product.productUrl != null && product.productUrl!.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductWebViewPage(
                      url: product.productUrl!,
                      title: product.name,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

