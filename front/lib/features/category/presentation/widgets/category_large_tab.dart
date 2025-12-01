import 'package:flutter/material.dart';
import '../../domain/entities/category_large.dart';
import '../../../../shared/styles/tokens.dart';

/// 대분류 카테고리 개별 탭 위젯 (기존 중분류 탭)
class CategoryLargeTab extends StatelessWidget {
  final CategoryLarge? category; // null이면 "전체"
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryLargeTab({
    super.key,
    this.category,
    this.isSelected = false,
    this.onTap,
  });

  String get _displayName {
    return category?.name ?? '전체';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 40,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _displayName,
                    style: TextStyle(
                      color: isSelected ? AppColors.activeColor : const Color(0xFF292D32),
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 1.66,
                      letterSpacing: 0.40,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 2,
                  color: AppColors.activeColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 대분류 카테고리 탭 리스트 위젯
class CategoryLargeTabList extends StatelessWidget {
  final List<CategoryLarge> categories;
  final CategoryLarge? selectedCategory;
  final Function(CategoryLarge?)? onCategorySelected;

  const CategoryLargeTabList({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categories.length + 1, // +1 for "전체"
      itemBuilder: (context, index) {
        if (index == 0) {
          // "전체" 탭
          return CategoryLargeTab(
            category: null,
            isSelected: selectedCategory == null,
            onTap: () {
              if (onCategorySelected != null) {
                onCategorySelected!(null);
              }
            },
          );
        } else {
          final category = categories[index - 1];
          return CategoryLargeTab(
            category: category,
            isSelected: selectedCategory == category,
            onTap: () {
              if (onCategorySelected != null) {
                onCategorySelected!(category);
              }
            },
          );
        }
      },
    );
  }
}

