import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/molecules/bottom_navigation.dart';
import '../../../../shared/utils/navigation_helper.dart';
import '../../../../shared/utils/weather_utils.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../app/router/app_router.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_info_card.dart';
import '../widgets/weather_temperature_section.dart';
import '../../../../shared/styles/weather_theme.dart';

/// 날씨 상세 페이지
class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  int _currentCharacterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  void _loadWeather() {
    print('🌤️ [WeatherPage] 날씨 정보 로드 중...');
    ref.read(weatherProvider.notifier).loadWeather();
  }

  void _onNavTap(int index) {
    // 같은 페이지면 무시
    if (index == 1) return;
    
    // 공통 네비게이션 헬퍼 사용
    NavigationHelper.handleBottomNavTap(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomNavHeight = 85.0;
    
    // 844 기준으로 비율 계산
    final baseHeight = 844.0;
    final heightRatio = screenHeight / baseHeight;

    final weatherAsync = ref.watch(weatherProvider);
    final weather = weatherAsync.value;
    
    // 날씨에 따른 텍스트 색상
    final textColor = WeatherTheme.getTextColorByWeather(
      weather?.getDisplayWeather() ?? '맑음'
    );

    // 날씨에 따른 배경 이미지 및 색상
    final backgroundImage = WeatherUtils.getWeatherBackgroundImage(
      weather?.precipitationType,
      weather?.weatherCondition, // skyState
    );
    final backgroundColor = WeatherUtils.getWeatherBackgroundColor(
      weather?.precipitationType,
      weather?.weatherCondition, // skyState
    );

    return Scaffold(
      body: Stack(
        children: [
          // 배경: 상단 이미지 + 하단 단색
          Positioned.fill(
            child: Column(
              children: [
                // 상단: 1:1 비율 이미지 (가로 = 세로 = screenWidth)
                SizedBox(
                  width: screenWidth,
                  height: screenWidth, // 1:1 비율
                  child: Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 이미지 로드 실패 시 단색으로 대체
                      return Container(color: backgroundColor);
                    },
                  ),
                ),
                // 하단: 단색
                Expanded(
                  child: Container(color: backgroundColor),
                ),
              ],
            ),
          ),
          
          // 콘텐츠 레이어
          Container(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                // 메인 콘텐츠
                SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: statusBarHeight),
                  
                  // 상단: 위치 정보
                  Padding(
                    padding: EdgeInsets.only(top: 25 * heightRatio), // 40 → 25로 축소
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Color(0xFFFB4A6E), size: 24), // 브랜드 컬러로 변경
                        const SizedBox(width: 5),
                        Text(
                          '현재 위치',
                          style: TextStyle(
                            color: textColor, // 날씨에 따라 동적으로 변경
                            fontSize: 15,
                            fontFamily: 'NanumSquare Neo',
                            fontWeight: FontWeight.w700,
                            height: 1.10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 캐릭터 이미지
                  Padding(
                    padding: EdgeInsets.only(top: 5 * heightRatio), // 10 → 5로 축소
                    child: SizedBox(
                      width: 240 * heightRatio, // 280 → 240으로 축소
                      height: 240 * heightRatio, // 280 → 240으로 축소
                      child: Center(
                        child: Image.asset(
                          AppConstants.characterImages[_currentCharacterIndex],
                          width: 240 * heightRatio, // 280 → 240으로 축소
                          height: 240 * heightRatio, // 280 → 240으로 축소
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  
                  // 온도 정보 (캐릭터 위로 올림)
                  Transform.translate(
                    offset: Offset(0, -40 * heightRatio), // -50 → -40 (아래로 10px)
                    child: WeatherTemperatureSection(
                      temperature: weather?.temperatureCurrent.round() ?? 19,
                      apparentTemp: weather?.temperatureFeelsLike.round(),
                      weather: weather?.getDisplayWeather() ?? '맑음',
                      maxTemp: weather?.temperatureMax.round() ?? 19,
                      minTemp: weather?.temperatureMin.round() ?? 19,
                      skyState: weather?.weatherCondition,
                      precipitationType: weather?.precipitationType,
                      textColor: textColor, // 텍스트 색상 전달
                    ),
                  ),
                  
                  // 날씨 정보 카드들
                  Transform.translate(
                    offset: Offset(0, -20 * heightRatio), // -30 → -20 (아래로 10px)
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Column(
                        children: [
                          // 첫 번째 줄: 체감온도, 강수, 미세먼지
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 체감온도 카드
                              ApparentTempCard(
                                apparentTemp: weather?.temperatureFeelsLike.round() ?? 19,
                                actualTemp: weather?.temperatureCurrent.round() ?? 19,
                              ),
                              // 강수 카드
                              PrecipitationCard(
                                probability: weather?.precipitationChance ?? 0,
                                amount: weather?.precipitationAmount,
                                precipitationType: weather?.precipitationType,
                              ),
                              // 미세먼지 카드
                              FineDustCard(
                                concentration: weather?.dustIndex ?? 50, // 기본값 50 (보통)
                              ),
                            ],
                          ),
                          const SizedBox(height: 8), // 10 → 8로 축소
                          // 두 번째 줄: 자외선, 습도, 바람
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // 자외선 카드
                              UvIndexCard(
                                uvIndex: weather?.uvIndex ?? 3, // 기본값 3 (보통)
                              ),
                              // 습도 카드
                              HumidityCard(
                                humidity: weather?.humidityCurrent ?? 50, // 기본값 50%
                              ),
                              // 바람 카드
                              WindCard(
                                windSpeed: weather?.windSpeed ?? 2.0, // 기본값 2.0 m/s
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 30 * heightRatio), // 20 → 30으로 증가
                  
                  // 접기 아이콘
                  GestureDetector(
                    onTap: () {
                      // 홈 페이지로 돌아가기
                      Navigator.pushReplacementNamed(context, AppRouter.home);
                    },
                    child: Transform.rotate(
                      angle: 1.5708, // 90도 (시계방향 90도) - 위 방향 화살표
                      child: Icon(
                        Icons.chevron_left,
                        color: textColor, // 날씨에 따라 동적으로 변경
                        size: 32,
                      ),
                    ),
                  ),
                  
                  // 하단 네비게이션 여백
                  SizedBox(height: (bottomNavHeight + 30) * heightRatio), // +20 → +30으로 증가
                ],
              ),
            ),
            
            // 하단 네비게이션
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavigation(
                currentIndex: 1, // 날씨 탭 활성화
                onTap: _onNavTap,
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

