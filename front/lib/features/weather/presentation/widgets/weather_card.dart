import 'package:flutter/material.dart';
import '../../../../shared/styles/weather_theme.dart';
import '../../../../shared/utils/weather_utils.dart';

/// 날씨 카드 위젯
class WeatherCard extends StatelessWidget {
  final String weather;
  final int temperature;
  final int? apparentTemp; // 체감온도
  final int maxTemp;
  final int minTemp;
  final String? weatherIconUrl;
  final String? characterImageUrl;
  final String? skyState; // 하늘 상태 코드 (DB01~DB04)
  final String? precipitationType; // 강수 유형 (없음, 비, 눈, 비/눈, 소나기)
  final double borderRadius; // 모서리 둥글기 (기본값: 20)
  final bool showExpandIcon; // 펼치기 아이콘 표시 여부
  final VoidCallback? onTap; // 카드 탭 콜백
  final VoidCallback? onExpandIconTap; // 펼치기 아이콘 탭 콜백
  final VoidCallback? onRefresh; // 새로고침 콜백
  final LinearGradient? gradient; // 배경 그라데이션 (null이면 날씨에 따라 자동)
  final int? fineDust; // 미세먼지 농도 (㎍/㎥)
  final int? uvIndex; // 자외선 지수 (1~11+)
  final int? rainProbability; // 강수확률 (%)

  const WeatherCard({
    super.key,
    this.weather = '맑음',
    this.temperature = 19,
    this.apparentTemp,
    this.maxTemp = 19,
    this.minTemp = 19,
    this.weatherIconUrl,
    this.characterImageUrl,
    this.skyState,
    this.precipitationType,
    this.borderRadius = 20.0,
    this.showExpandIcon = false,
    this.onTap,
    this.onExpandIconTap,
    this.onRefresh,
    this.gradient,
    this.fineDust,
    this.uvIndex,
    this.rainProbability,
  });

  @override
  Widget build(BuildContext context) {
    // width는 Positioned의 left/right로 결정되므로 제거
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 25, 15, 8), // 하단 패딩 축소 (15 → 8)
        decoration: BoxDecoration(
          color: WeatherUtils.getWeatherBackgroundColor(
            precipitationType,
            skyState,
          ), // 날씨에 따른 단색 배경
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 날씨 정보 - Stack으로 중앙 정렬
            SizedBox(
              height: 80, // 80px 유지
              child: Stack(
                clipBehavior: Clip.none, // 오버플로우를 잘라내지 않음
                children: [
                  // 왼쪽: 날씨/강수 이모지
                  Positioned(
                    left: 0,
                    top: showExpandIcon ? 30 : 10, // 헤더 모드일 때 위로 (30 → 10)
                    child: SizedBox(
                      width: 60,
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          child: Text(
                            _getWeatherEmoji(),
                            style: const TextStyle(fontSize: 45),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // 중앙: 날씨 정보 (절대 중앙)
                  Positioned.fill(
                    child: OverflowBox(
                      maxHeight: double.infinity, // 높이 제약 무시
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 날씨 상태 + 온도 (오른쪽으로 이동)
                          Transform.translate(
                            offset: Offset(10, showExpandIcon ? 8 : 0), // 헤더 모드일 때 위로
                            child: Transform.scale(
                              scale: 0.88,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  // 날씨 상태 (작은 글씨)
                                  Text(
                                    weather,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontFamily: 'NanumGothicCoding',
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // 온도 (큰 글씨)
                                  Text(
                                    '$temperature°',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 34,
                                      fontFamily: 'S-Core Dream',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  // 체감온도
                                  if (apparentTemp != null) ...[
                                    const SizedBox(width: 3),
                                    Text(
                                      '체감 $apparentTemp°',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                        fontFamily: 'S-Core Dream',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                  // 새로고침 버튼 (헤더 모드일 때만 표시)
                                  if (onRefresh != null && !showExpandIcon) ...[
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: onRefresh,
                                      child: Container(
                                        width: 50, // 터치 영역 50x50
                                        height: 50,
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.refresh,
                                          color: Colors.white70,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // 최저/최고 기온 (독립적으로 가운데 정렬)
                          Transform.scale(
                            scale: 0.88,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 최저 온도 (파란색 온도계)
                                Icon(
                                  WeatherUtils.thermometerIcon,
                                  color: WeatherUtils.minTempColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '최저 $minTemp°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'S-Core Dream',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // 최고 온도 (빨간색 온도계)
                                Icon(
                                  WeatherUtils.thermometerIcon,
                                  color: WeatherUtils.maxTempColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '최고 $maxTemp°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'S-Core Dream',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 미세먼지, 자외선, 강수확률 (독립적으로 가운데 정렬)
                          if (fineDust != null || uvIndex != null || rainProbability != null) ...[
                            const SizedBox(height: 6),
                            Transform.scale(
                              scale: 0.88,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 미세먼지
                                  if (fineDust != null) ...[
                                    Icon(
                                      Icons.masks, // 마스크 아이콘
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      WeatherUtils.getFineDustLevelText(fineDust!),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontFamily: 'S-Core Dream',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                  if (fineDust != null && (uvIndex != null || rainProbability != null))
                                    const SizedBox(width: 4),
                                  // 자외선
                                  if (uvIndex != null) ...[
                                    Icon(
                                      Icons.wb_sunny, // 해 아이콘
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      WeatherUtils.getUvLevelText(uvIndex!),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontFamily: 'S-Core Dream',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                  if (uvIndex != null && rainProbability != null)
                                    const SizedBox(width: 4),
                                  // 강수확률
                                  if (rainProbability != null) ...[
                                    Icon(
                                      Icons.water_drop, // 물방울 아이콘
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '$rainProbability%',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontFamily: 'S-Core Dream',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  // 오른쪽: 캐릭터 이미지
                  Positioned(
                    right: -15, // 오른쪽으로 15px 이동 (-10 → -15)
                    top: showExpandIcon ? 15 : 0, // 헤더 모드일 때 위로 (15 → 0)
                    child: SizedBox(
                      width: 100,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 캐릭터 이미지
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              image: characterImageUrl != null
                                  ? DecorationImage(
                                      image: AssetImage(characterImageUrl!),
                                      fit: BoxFit.contain,
                                    )
                                  : null,
                            ),
                            child: characterImageUrl == null
                                ? const Icon(Icons.person, color: Colors.white, size: 80)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 펼치기 아이콘 (카드 내부 하단)
            if (showExpandIcon)
              GestureDetector(
                onTap: onExpandIconTap, // 펼치기 아이콘 클릭 시 콜백
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Transform.rotate(
                    angle: -1.5708, // -90도 (반시계방향 90도) - 아래 방향 화살표
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// 날씨/강수 이모지 반환
  /// 강수 상태가 "없음"이 아니면 강수 이모지 우선, 그렇지 않으면 하늘 상태 이모지
  String _getWeatherEmoji() {
    // 1. 강수 상태 우선
    if (precipitationType != null && 
        precipitationType != '없음' && 
        precipitationType!.isNotEmpty) {
      return WeatherUtils.getPrecipitationEmojiByName(precipitationType!);
    }
    
    // 2. 하늘 상태 (skyState가 있으면 사용)
    if (skyState != null && skyState!.isNotEmpty) {
      return WeatherUtils.getSkyStateEmoji(skyState!);
    }
    
    // 3. 기본값: 맑음
    return '☀️';
  }
}


