import 'package:flutter/material.dart';
import '../../../../shared/styles/tokens.dart';

/// 인기 검색어 순위 변동 타입
enum RankChangeType {
  up,    // 상승 (빨간색)
  down,  // 하락 (파란색)
  new_,  // 신규 (NEW)
  none,  // 변화 없음
}

/// 인기 검색어 아이템 데이터 모델
class PopularSearchItem {
  final int rank;
  final String keyword;
  final RankChangeType? rankChange;
  final int? changeValue; // 순위 변동 값 (rankChange가 up/down일 때)

  const PopularSearchItem({
    required this.rank,
    required this.keyword,
    this.rankChange,
    this.changeValue,
  });
}

/// 인기 검색어 개별 아이템 위젯
class PopularSearchItemWidget extends StatelessWidget {
  final PopularSearchItem item;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const PopularSearchItemWidget({
    super.key,
    required this.item,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // 순위
            Positioned(
              left: 7,
              top: height == 35 ? 6 : 5,
              child: Text(
                item.rank.toString(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 2,
                  letterSpacing: 0.15,
                ),
              ),
            ),
            // 검색어
            Positioned(
              left: 26,
              top: height == 35 ? 6 : 5,
              right: item.rankChange != null && item.rankChange != RankChangeType.none ? 35 : 8, // 순위 변동 표시 공간 확보
              child: Text(
                item.keyword,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis, // 말줄임 처리
                maxLines: 1, // 한 줄로 제한
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w400,
                  height: 2,
                  letterSpacing: 0.15,
                ),
              ),
            ),
            // 순위 변동 표시
            if (item.rankChange == RankChangeType.up)
              Positioned(
                right: 8,
                top: height == 35 ? 10 : 9,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 세모 아이콘 (상승)
                    Icon(
                      Icons.arrow_drop_up,
                      size: 16,
                      color: AppColors.rankUp,
                    ),
                    // 상승 단계 숫자
                    Text(
                      item.changeValue.toString(),
                      style: const TextStyle(
                        color: AppColors.rankUp,
                        fontSize: 10,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              )
            else if (item.rankChange == RankChangeType.down)
              Positioned(
                right: 8,
                top: height == 35 ? 10 : 9,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 거꾸로 세모 아이콘 (하락)
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: AppColors.rankDown,
                    ),
                    // 하락 단계 숫자
                    Text(
                      item.changeValue.toString(),
                      style: const TextStyle(
                        color: AppColors.rankDown,
                        fontSize: 10,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              )
            else if (item.rankChange == RankChangeType.new_)
              Positioned(
                right: 8,
                top: height == 35 ? 11 : 10,
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: AppColors.rankNew,
                    fontSize: 10,
                    fontFamily: 'S-Core Dream',
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

