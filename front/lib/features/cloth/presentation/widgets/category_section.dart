import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../category/domain/entities/gender.dart';
import '../../../category/domain/entities/category_large.dart';
import '../../../category/domain/entities/category_small.dart';
import '../../domain/entities/cloth_entity.dart';
import '../../../category/presentation/widgets/category_small_tag.dart';
import '../providers/product_providers.dart';
import '../pages/product_webview_page.dart';
import 'cloth_card.dart';

/// 카테고리별 섹션 위젯
class CategorySection extends ConsumerStatefulWidget {
  final CategoryLarge category;
  final List<ClothEntity> clothes;
  final Gender? selectedGender;
  final Function(String largeCategoryName, String? smallCategoryName)? onMoreTap;

  const CategorySection({
    super.key,
    required this.category,
    required this.clothes,
    this.selectedGender,
    this.onMoreTap,
  });

  @override
  ConsumerState<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends ConsumerState<CategorySection> {
  CategorySmall? _selectedSmallCategory;
  List<ClothEntity> _displayClothes = [];

  @override
  void initState() {
    super.initState();
    // 초기 데이터는 props로 받은 데이터 사용
    _displayClothes = widget.clothes;
    // 소분류 체크는 Splash에서 이미 완료됨
  }

  @override
  void didUpdateWidget(CategorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 성별이 변경되었으면 소분류 선택 초기화 및 데이터 리셋
    if (oldWidget.selectedGender?.name != widget.selectedGender?.name) {
      setState(() {
        _selectedSmallCategory = null;
        _displayClothes = widget.clothes; // "전체" 상태로 복귀
      });
    }
    
    // props로 전달된 clothes가 변경되면 업데이트
    if (oldWidget.clothes != widget.clothes && _selectedSmallCategory == null) {
      setState(() {
        _displayClothes = widget.clothes;
      });
    }
  }

  /// 소분류 필터링 (온도 기반 상품 데이터에서 필터링)
  void _fetchFilteredProducts(CategorySmall smallCategory) {
    setState(() {
      _selectedSmallCategory = smallCategory;
      // props로 받은 데이터에서 해당 소분류만 필터링
      _displayClothes = widget.clothes
          .where((cloth) => cloth.smallCategory == smallCategory.name)
          .toList();
        });
  }
  
  /// "전체" 태그로 되돌리기
  void _resetToAllProducts() {
    setState(() {
      _selectedSmallCategory = null;
      _displayClothes = widget.clothes;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 실제 데이터가 있는 소분류만 필터링
    final uniqueSmallCategories = <String>{};
    for (final cloth in widget.clothes) {
      if (cloth.smallCategory != null && cloth.smallCategory!.isNotEmpty) {
        uniqueSmallCategories.add(cloth.smallCategory!);
      }
    }
    
    // 소분류 이름이 실제 데이터에 있는 것만 표시
    final availableSmalls = widget.category.smalls
        .where((small) => uniqueSmallCategories.contains(small.name))
        .toList();
    
    // 고정 크기 사용
    final titleFontSize = 18.0;
    final moreFontSize = 12.0;
    final emptyFontSize = 14.0;
    final horizontalPadding = 20.0;
    final tagHeight = 35.0;
    final cardHeight = 240.0;
    final spacing10 = 10.0;
    final spacing15 = 15.0;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 대분류 제목과 더보기
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.category.name,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: titleFontSize,
                    fontFamily: 'S-Core Dream',
                    fontWeight: FontWeight.w500,
                    height: 1.66,
                    letterSpacing: 0.40,
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onMoreTap?.call(
                    widget.category.name, // 대분류 이름
                    _selectedSmallCategory?.name, // 소분류 이름 (null이면 "전체")
                  ),
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      color: const Color(0xFF9AA6B2),
                      fontSize: moreFontSize,
                      fontFamily: 'S-Core Dream',
                      fontWeight: FontWeight.w600,
                      height: 1.66,
                      letterSpacing: 0.40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing10),
          // 소분류 태그 리스트 (가로 스크롤) - Splash에서 미리 로드한 데이터 사용
          SizedBox(
            height: tagHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: availableSmalls.length + 1, // +1 for "전체"
              separatorBuilder: (context, index) => SizedBox(width: spacing10),
              itemBuilder: (context, index) {
                if (index == 0) {
                  // "전체" 태그
                  return CategorySmallTag(
                    label: '전체',
                    isSelected: _selectedSmallCategory == null,
                    onTap: _resetToAllProducts,
                  );
                } else {
                  final small = availableSmalls[index - 1];
                  return CategorySmallTag(
                    category: small,
                    isSelected: _selectedSmallCategory == small,
                    onTap: () => _fetchFilteredProducts(small),
                  );
                }
              },
            ),
          ),
          SizedBox(height: spacing15),
          // 의류 카드 리스트 (가로 스크롤, 최대 20개)
          SizedBox(
            height: cardHeight,
            child: _displayClothes.isEmpty
                        ? Center(
                            child: Text(
                              '상품이 없습니다',
                              style: TextStyle(
                                color: const Color(0xFF9AA6B2),
                                fontSize: emptyFontSize,
                              ),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            itemCount: _displayClothes.length > 20 ? 20 : _displayClothes.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 0),
                            itemBuilder: (context, index) {
                              final cloth = _displayClothes[index];
                              return ClothCard(
                                key: ValueKey('${cloth.productId}_${widget.selectedGender?.name ?? "all"}_${_selectedSmallCategory?.name ?? "all"}'), // 상태 변경 시 재생성
                                productId: cloth.productId,
                                name: cloth.name,
                                brand: cloth.brand,
                                productUrl: cloth.productUrl,
                                representativeImageUrl: cloth.representativeImageUrl,
                                originalPrice: cloth.originalPrice,
                                colors: cloth.colors,
                                smallCategoryName: cloth.smallCategory,
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
                          ),
          ),
        ],
      ),
    );
  }
}

