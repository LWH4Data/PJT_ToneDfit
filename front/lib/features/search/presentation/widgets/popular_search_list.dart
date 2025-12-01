import 'package:flutter/material.dart';
import 'popular_search_item.dart';

/// 인기 검색어 리스트 위젯 (2열 5행 그리드)
class PopularSearchList extends StatelessWidget {
  final List<PopularSearchItem> items;
  final Function(String keyword)? onItemTap;

  const PopularSearchList({
    super.key,
    required this.items,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 40; // 좌우 20px 패딩
    final itemWidth = containerWidth / 2;
    
    // 최대 10개 항목 (2열 5행)
    final displayItems = items.take(10).toList();

    // 각 아이템의 위치 계산
    // 배치 순서: 1-6, 2-7, 3-8, 4-9, 5-10
    final itemPositions = <Map<String, dynamic>>[];
    for (int i = 0; i < displayItems.length; i++) {
      final rowIndex = i < 5 ? i : i - 5; // 왼쪽 열(0-4), 오른쪽 열(0-4)
      final colIndex = i < 5 ? 0 : 1; // 왼쪽 열 = 0, 오른쪽 열 = 1
      
      final top = rowIndex == 0 
          ? 0.0 
          : rowIndex == 1 
              ? 35.0 
              : rowIndex == 2 
                  ? 69.0 
                  : rowIndex == 3 
                      ? 104.0 
                      : 138.0;
      final left = colIndex == 0 ? 0.0 : itemWidth;
      final height = rowIndex == 0 || rowIndex == 2 || rowIndex == 4 ? 35.0 : 34.0;
      
      itemPositions.add({
        'item': displayItems[i],
        'top': top,
        'left': left,
        'height': height,
      });
    }

    return Container(
      width: containerWidth,
      height: 173,
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      child: Stack(
        children: [
          // 아이템 배치
          ...itemPositions.map((pos) {
            return Positioned(
              left: pos['left'],
              top: pos['top'],
              child: PopularSearchItemWidget(
                item: pos['item'],
                width: itemWidth,
                height: pos['height'],
                onTap: () => onItemTap?.call(pos['item'].keyword),
              ),
            );
          }),
          // 가로 구분선
          Positioned(
            left: 0,
            top: 35,
            child: Container(
              width: containerWidth,
              height: 0.5,
              color: const Color(0x7F292D32),
            ),
          ),
          Positioned(
            left: 0,
            top: 69,
            child: Container(
              width: containerWidth,
              height: 0.5,
              color: const Color(0x7F292D32),
            ),
          ),
          Positioned(
            left: 0,
            top: 104,
            child: Container(
              width: containerWidth,
              height: 0.5,
              color: const Color(0x7F292D32),
            ),
          ),
          Positioned(
            left: 0,
            top: 138,
            child: Container(
              width: containerWidth,
              height: 0.5,
              color: const Color(0x7F292D32),
            ),
          ),
          Positioned(
            left: 0,
            top: 173,
            child: Container(
              width: containerWidth,
              height: 0.5,
              color: const Color(0x7F292D32),
            ),
          ),
        ],
      ),
    );
  }
}

