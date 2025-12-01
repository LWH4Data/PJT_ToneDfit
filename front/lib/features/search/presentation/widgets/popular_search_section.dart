import 'package:flutter/material.dart';
import 'popular_search_item.dart';
import 'popular_search_list.dart';

/// 인기 검색어 섹션 위젯
class PopularSearchSection extends StatelessWidget {
  final List<PopularSearchItem> items;
  final DateTime? lastUpdated;
  final Function(String keyword)? onItemTap;
  final VoidCallback? onRefresh;

  const PopularSearchSection({
    super.key,
    required this.items,
    this.lastUpdated,
    this.onItemTap,
    this.onRefresh,
  });

  /// 업데이트 시간 텍스트 생성 (timestamp 기반)
  String _getUpdateTimeText() {
    if (lastUpdated == null) {
      return '업데이트 중...';
    }
    
    final month = lastUpdated!.month;
    final day = lastUpdated!.day;
    final hour = lastUpdated!.hour;
    final minute = lastUpdated!.minute;
    
    return '$month월 ${day}일 ${hour}시 ${minute}분 기준';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 40; // 좌우 20px 패딩
    
    return SizedBox(
      width: containerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (제목 + 설명 + 업데이트 시간)
          SizedBox(
            width: double.infinity,
            height: 27,
            child: Stack(
              children: [
                // "인기 검색어" 제목
                const Positioned(
                  left: 0,
                  top: 0,
                  child: Text(
                    '인기 검색어',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                      height: 1.60,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                // 설명 텍스트
                Positioned(
                  left: 78,
                  top: -3,
                  right: 150, // 업데이트 시간 공간 확보
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '테스트를 위해 사용자가',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.70),
                          fontSize: 8,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                        ),
                      ),
                      Text(
                        '검색어 순위 요청을 할 수',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.70),
                          fontSize: 8,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                        ),
                      ),
                      Text(
                        '있습니다. 새로고침을 눌러주세요',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.70),
                          fontSize: 8,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 1.20,
                        ),
                      ),
                    ],
                  ),
                ),
                // 업데이트 시간 + 새로고침 버튼
                Positioned(
                  right: 0,
                  top: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getUpdateTimeText(),
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.70),
                          fontSize: 12,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          height: 2,
                        ),
                      ),
                      if (onRefresh != null) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onRefresh,
                          child: const Icon(
                            Icons.refresh,
                            size: 16,
                            color: Color(0xFF9AA6B2),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // 인기 검색어 리스트
          PopularSearchList(
            items: items,
            onItemTap: onItemTap,
          ),
        ],
      ),
    );
  }
}

