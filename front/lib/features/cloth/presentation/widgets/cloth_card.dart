import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/color_data.dart';
import 'color_circle.dart';

/// 상품 카드 위젯 (3D 뒤집기 애니메이션)
class ClothCard extends StatefulWidget {
  final String productId;
  final String name;
  final String brand;
  final String productUrl;
  final String representativeImageUrl;
  final int originalPrice;
  final List<String> colors;
  final String? smallCategoryName;
  final VoidCallback? onTap;
  final double? width;  // 카드 너비 (선택적)
  final double? height; // 카드 높이 (선택적)

  const ClothCard({
    super.key,
    required this.productId,
    required this.name,
    required this.brand,
    required this.productUrl,
    required this.representativeImageUrl,
    required this.originalPrice,
    required this.colors,
    this.smallCategoryName,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<ClothCard> createState() => _ClothCardState();
}

class _ClothCardState extends State<ClothCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ClothCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 상품이 변경되면 플립 상태 초기화
    if (oldWidget.productId != widget.productId) {
      _resetFlip();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() => _isFlipped = !_isFlipped);
  }
  
  void _resetFlip() {
    if (_isFlipped) {
      _controller.reverse();
      setState(() => _isFlipped = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 크기 계산 (외부에서 전달되지 않으면 기본값 사용)
    final cardWidth = widget.width ?? 120.0;
    final cardHeight = widget.height ?? 240.0;
    
    // 비율에 따른 크기 계산
    final imageHeight = cardHeight * 0.65;  // 65% 이미지
    final textHeight = cardHeight * 0.35;   // 35% 텍스트
    final fontSize = (cardWidth * 0.09).clamp(9.0, 12.0);   // 폰트 크기 줄임
    final borderRadius = 0.0;
    final spacing = (cardHeight * 0.008).clamp(1.5, 3.0);   // 간격 줄임

    return GestureDetector(
      onTap: _toggleFlip,
      child: SizedBox(
      width: cardWidth,
      height: cardHeight,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            // 회전 각도 계산 (0 -> π)
            final angle = _animation.value * pi;
            // 앞면인지 뒷면인지 판단
            final isFront = angle < pi / 2;
            
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 원근감
                ..rotateY(angle),
              child: isFront ? _buildFrontCard(
                cardWidth, cardHeight, imageHeight, textHeight, 
                fontSize, borderRadius, spacing
              ) : Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateY(pi), // 뒷면 뒤집기
                child: _buildBackCard(cardWidth, cardHeight),
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// 앞면 카드
  Widget _buildFrontCard(
    double cardWidth,
    double cardHeight,
    double imageHeight,
    double textHeight,
    double fontSize,
    double borderRadius,
    double spacing,
  ) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 이미지 영역 (120x150)
          SizedBox(
            width: cardWidth,
            height: imageHeight,
            child: Stack(
              children: [
                // 이미지
                Container(
                  width: cardWidth,
                  height: imageHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Image.network(
                    widget.representativeImageUrl,
                    fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.white,
                          child: Center(
                            child: CircularProgressIndicator(
                            color: const Color(0xFFFB4A6E),
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.white,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 30.0,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // 색상 리스트 (하단 중앙, 가로 스크롤)
              if (widget.colors.isNotEmpty)
                  Positioned(
                    left: 0,
                    bottom: 4,
                    right: 0,
                    height: 10,
                    child: Center(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                        children: widget.colors.map((colorName) {
                            final colorEntity = ColorData.findColorByName(colorName);
                            if (colorEntity == null) return const SizedBox.shrink();
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: ColorCircle(
                                color: colorEntity,
                                size: 10.0,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 텍스트 영역 (고정 높이)
        ClipRect(
          child: Container(
            width: cardWidth,
            height: textHeight,
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: spacing, horizontal: 5.0),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 브랜드명
                Text(
                widget.brand,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.50),
                    fontSize: fontSize,
                    fontFamily: 'S-Core Dream',
                    fontWeight: FontWeight.w500,
                  height: 1.2,
                  letterSpacing: 0.20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing),
                // 상품명
                Text(
                widget.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontFamily: 'NanumSquare Neo',
                    fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: 0.20,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing),
                // 소분류 태그 (API 응답에서 받은 값 사용)
              if (widget.smallCategoryName != null && widget.smallCategoryName!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF476A62).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                    widget.smallCategoryName!,
                      textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF476A62),
                      fontSize: 9,
                        fontFamily: 'S-Core Dream',
                        fontWeight: FontWeight.w500,
                      height: 1.1,
                      letterSpacing: 0.15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              if (widget.smallCategoryName != null) SizedBox(height: spacing),
                // 가격
                Text(
                '${widget.originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  height: 1.2,
                  letterSpacing: 0.20,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// 뒷면 카드
  Widget _buildBackCard(double cardWidth, double cardHeight) {
    // 뒷면 요소 크기 계산
    final backFontSize = (cardWidth * 0.095).clamp(10.0, 14.0);
    final buttonHeight = (cardHeight * 0.15).clamp(32.0, 40.0);
    final padding = (cardWidth * 0.08).clamp(8.0, 16.0);
    
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF476A62).withOpacity(0.7),
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(            padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.brand,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: backFontSize * 0.92,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: padding * 0.25),
                Text(
                  widget.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: backFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: padding * 0.5),
                Text(
                  '${widget.originalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: backFontSize * 1.08,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: padding),
          // 상품 보기 버튼
          ElevatedButton.icon(
            onPressed: () {
              if (widget.onTap != null) {
                widget.onTap!();
              }
            },
            icon: Icon(Icons.shopping_bag, size: backFontSize * 1.2),
            label: Text(
              '상품 보기',
              style: TextStyle(fontSize: backFontSize, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF476A62),
              padding: EdgeInsets.symmetric(horizontal: padding * 1.5, vertical: padding * 0.6),
              minimumSize: Size(cardWidth * 0.6, buttonHeight),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}