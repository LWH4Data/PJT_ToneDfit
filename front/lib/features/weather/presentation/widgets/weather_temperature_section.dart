import 'package:flutter/material.dart';
import '../../../../shared/utils/weather_utils.dart';

/// 날씨 온도 정보 섹션
/// 현재 온도, 체감온도, 날씨 상태, 최고/최저 온도를 표시하는 위젯
class WeatherTemperatureSection extends StatelessWidget {
  final int temperature; // 현재 온도
  final int? apparentTemp; // 체감온도
  final String weather; // 날씨 상태
  final int maxTemp; // 최고 온도
  final int minTemp; // 최저 온도
  final String? skyState; // 하늘 상태 코드 (DB01~DB04)
  final String? precipitationType; // 강수 유형 (없음, 비, 눈, 비/눈, 소나기)
  final Color? textColor; // 텍스트 색상 (null이면 기본 색상)

  const WeatherTemperatureSection({
    super.key,
    required this.temperature,
    this.apparentTemp,
    required this.weather,
    required this.maxTemp,
    required this.minTemp,
    this.skyState,
    this.precipitationType,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 현재 온도
        Text(
          '$temperature°',
          style: TextStyle(
            color: textColor ?? const Color(0xFF292D32),
            fontSize: 35,
            fontFamily: 'S-Core Dream',
            fontWeight: FontWeight.w500,
            height: 1.10,
          ),
          textAlign: TextAlign.center,
        ),
        // 체감온도
        if (apparentTemp != null) ...[
          const SizedBox(height: 2),
          Text(
            '체감 $apparentTemp°',
            style: TextStyle(
              color: textColor ?? const Color(0xFF292D32),
              fontSize: 14,
              fontFamily: 'S-Core Dream',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        const SizedBox(height: 4),
        // 날씨 상태 아이콘 + 텍스트
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 날씨 이모지 (배경 제거)
            Text(
              _getWeatherEmoji(),
              style: const TextStyle(fontSize: 25), // 12 → 25로 크기 증가
            ),
            const SizedBox(width: 5), // 3 → 5로 간격 증가
            Text(
              _getWeatherText(),
              style: TextStyle(
                color: textColor ?? const Color(0xFF292D32),
                fontSize: 20,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 최고/최저 온도
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '최고↑ $maxTemp°',
              style: TextStyle(
                color: textColor ?? const Color(0xFF292D32),
                fontSize: 15,
                fontFamily: 'S-Core Dream',
                fontWeight: FontWeight.w500,
                height: 1.60,
                letterSpacing: 0.38,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '최저↓ $minTemp°',
              style: TextStyle(
                color: textColor ?? const Color(0xFF292D32),
                fontSize: 15,
                fontFamily: 'S-Core Dream',
                fontWeight: FontWeight.w500,
                height: 1.60,
                letterSpacing: 0.38,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 날씨 이모지 반환
  String _getWeatherEmoji() {
    // 1. 강수 상태 우선
    if (precipitationType != null && 
        precipitationType != '없음' && 
        precipitationType!.isNotEmpty) {
      return WeatherUtils.getPrecipitationEmojiByName(precipitationType!);
    }
    
    // 2. 하늘 상태
    if (skyState != null && skyState!.isNotEmpty) {
      return WeatherUtils.getSkyStateEmoji(skyState!);
    }
    
    // 3. 기본값
    return '☀️';
  }
  
  /// 날씨 텍스트 반환
  String _getWeatherText() {
    // 1. 강수 상태 우선
    if (precipitationType != null && 
        precipitationType != '없음' && 
        precipitationType!.isNotEmpty) {
      return precipitationType!;
    }
    
    // 2. 하늘 상태 코드 → 텍스트 변환
    if (skyState != null && skyState!.isNotEmpty) {
      return WeatherUtils.getSkyStateText(skyState!);
    }
    
    // 3. 기본값
    return weather;
  }
}

