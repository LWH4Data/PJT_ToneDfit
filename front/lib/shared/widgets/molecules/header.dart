import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../styles/tokens.dart';
import '../../../app/router/app_router.dart';

class Header extends StatelessWidget {
  final bool showDescription; // 설명 텍스트 표시 여부
  final VoidCallback? onRefresh; // 새로고침 콜백
  
  const Header({
    super.key,
    this.showDescription = true, // 기본값: 표시
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // 카테고리 페이지 입력 부분과 동일한 높이 (53 + 40 = 93px)
    final headerHeight = 93.0;
    final headerWidth = screenWidth; // 화면 전체 너비

    // 상태바 색상을 흰색으로 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // 상태바 배경색 흰색
        statusBarIconBrightness: Brightness.dark, // 아이콘 색상 어둡게
        statusBarBrightness: Brightness.light, // iOS용 설정
      ),
    );

    return Container(
      width: headerWidth,
      height: headerHeight,
      color: Colors.white, // 배경색 흰색
      child: Stack(
        children: [
          // 톤디핏 로고 텍스트 + 설명 (왼쪽 정렬)
          Positioned(
            left: 20, // 왼쪽 패딩 20px
            right: 60, // 검색 아이콘 공간 확보 (20 + 24 + 16)
            top: headerHeight * 0.5 - 10, // 중앙보다 아래로
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 로고 클릭 시 홈으로 이동
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.home,
                      (route) => false,
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: '톤디',
                          style: TextStyle(
                            color: Color(0xFF292D32),
                            fontSize: 25,
                            fontFamily: 'S-Core Dream',
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: '핏',
                          style: GoogleFonts.roboto(
                            color: const Color(0xFFFB4A6E),
                            fontSize: 35,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 새로고침 버튼
                if (onRefresh != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onRefresh,
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.refresh,
                        color: Color(0xFFFB4A6E), // 브랜드 컬러
                        size: 24,
                      ),
                    ),
                  ),
                ],
                if (showDescription) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5), // 로고와 baseline 맞춤
                      child: Text(
                        '날씨별 의류 추천을 위해 예시 데이터를 넣었습니다. 톤디핏 옆 새로고침을 눌러 확인해 주세요.',
                        style: const TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 8,
                          fontFamily: 'S-Core Dream',
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 3, // 최대 2줄
                        overflow: TextOverflow.ellipsis, // 넘치면 ... 표시
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 검색 아이콘
          Positioned(
            right: 20, // 오른쪽 패딩 20px
            top: headerHeight * 0.5 + 2, // 중앙보다 살짝 아래
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRouter.search);
              },
              child: Icon(
                Icons.search_rounded, // 둥근 스타일로 변경
                size: 24,
                color: AppColors.textPrimary.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
