import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_large.dart';
import '../../domain/entities/category_small.dart';
import '../../domain/entities/gender.dart';
import 'category_small_card.dart';
import '../../../cloth/presentation/providers/product_providers.dart';

/// 대분류 섹션 위젯 (기존 중분류 섹션)
class CategoryLargeSection extends ConsumerStatefulWidget {
  final CategoryLarge category;
  final Gender? selectedGender;
  final Function(CategorySmall)? onSmallCategoryTap;

  const CategoryLargeSection({
    super.key,
    required this.category,
    this.selectedGender,
    this.onSmallCategoryTap,
  });

  @override
  ConsumerState<CategoryLargeSection> createState() => _CategoryLargeSectionState();
}

class _CategoryLargeSectionState extends ConsumerState<CategoryLargeSection> {
  // 소분류 체크는 Splash에서 이미 완료됨
  
  // 화면 너비에 따라 열 수 계산
  int _calculateCrossAxisCount(double screenWidth) {
    // 390px 기준으로 4열
    if (screenWidth <= 390) {
      return 4;
    } else if (screenWidth <= 500) {
      return 5;
    } else if (screenWidth <= 600) {
      return 6;
    } else {
      return 7;
    }
  }

  // 카드 간 간격 계산
  double _calculateSpacing(double screenWidth) {
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);
    final cardWidth = 87.50;
    final sectionPadding = 20.0 * 2; // 좌우 패딩
    final availableWidth = screenWidth - sectionPadding;
    final totalCardsWidth = crossAxisCount * cardWidth;
    final remainingSpace = availableWidth - totalCardsWidth;
    
    // 남은 공간을 (열 수 - 1)개의 간격으로 나눔
    if (remainingSpace > 0 && crossAxisCount > 1) {
      return remainingSpace / (crossAxisCount - 1);
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // 모든 소분류 표시 (API 개수 확인 제거)
    final availableSmalls = widget.category.smalls;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = 87.50;
    final spacing = _calculateSpacing(screenWidth);
    final sectionPadding = 20.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: sectionPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 대분류 제목
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              widget.category.name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                height: 1.71,
                letterSpacing: 0.40,
              ),
            ),
          ),
          // 소분류 카드 그리드 (데이터 있는 것만)
          Wrap(
            spacing: spacing,
            runSpacing: 40.0, // 행 간격 증가
            alignment: WrapAlignment.start,
            children: availableSmalls.map((smallCategory) {
              return SizedBox(
                width: cardWidth,
                child: CategorySmallCard(
                  category: smallCategory,
                  onTap: () {
                    if (widget.onSmallCategoryTap != null) {
                      widget.onSmallCategoryTap!(smallCategory);
                    }
                  },
                ),
              );
            }).toList(),
          ),
          // 구분선
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              width: double.infinity,
              height: 1.0,
              color: Colors.black.withOpacity(0.10),
            ),
          ),
        ],
      ),
    );
  }
}

