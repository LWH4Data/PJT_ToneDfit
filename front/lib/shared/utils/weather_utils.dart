import 'package:flutter/material.dart';

/// 날씨 관련 유틸리티 함수 모음
class WeatherUtils {
  /// 최저 온도 아이콘 색상
  static const Color minTempColor = Color(0xFF0003FF); // 순수 파란색
  
  /// 최고 온도 아이콘 색상
  static const Color maxTempColor = Color(0xFFFF0000); // 순수 빨간색
  
  /// 온도계 아이콘
  static const IconData thermometerIcon = Icons.thermostat;
  
  /// 날씨 배경 이미지 경로 반환 (String 버전 - 강수 유무 우선)
  static String getWeatherBackgroundImage(String? precipitationType, String? skyState) {
    // 강수 유무 우선 (String)
    if (precipitationType != null && 
        precipitationType != '없음' && 
        precipitationType != '0' &&
        precipitationType.isNotEmpty) {
      switch (precipitationType) {
        case '비':
          return 'assets/weather/비.png';
        case '비/눈':
          return 'assets/weather/비눈.png';
        case '눈':
          return 'assets/weather/눈.png';
        case '소나기':
          return 'assets/weather/소나기.png';
        case '빗방울':
          return 'assets/weather/빗방울.png';
        case '빗방울눈날림':
          return 'assets/weather/빗방울눈날림.png';
        case '눈날림':
          return 'assets/weather/눈날림.png';
      }
    }
    
    // 하늘 상태
    if (skyState != null) {
      switch (skyState) {
        case 'DB01':
          return 'assets/weather/맑음.png';
        case 'DB02':
          return 'assets/weather/구름조금.png';
        case 'DB03':
          return 'assets/weather/구름많음.png';
        case 'DB04':
          return 'assets/weather/흐림.png';
      }
    }
    
    // 기본값
    return 'assets/weather/맑음.png';
  }
  
  /// 날씨 배경 단색 반환 (String 버전 - 강수 유무 우선)
  static Color getWeatherBackgroundColor(String? precipitationType, String? skyState) {
    // 강수 유무 우선 (String)
    if (precipitationType != null && 
        precipitationType != '없음' && 
        precipitationType != '0' &&
        precipitationType.isNotEmpty) {
      switch (precipitationType) {
        case '비':
          return const Color(0xFFB9C7CC); // 비
        case '비/눈':
          return const Color(0xFFD1DEE8); // 비/눈
        case '눈':
          return const Color(0xFFD7E6EC); // 눈
        case '소나기':
          return const Color(0xFF80B1C3); // 소나기
        case '빗방울':
          return const Color(0xFF92D5E9); // 빗방울
        case '빗방울눈날림':
          return const Color(0xFFB9D9E3); // 빗방울눈날림
        case '눈날림':
          return const Color(0xFFC7E1EF); // 눈날림
      }
    }
    
    // 하늘 상태
    if (skyState != null) {
      switch (skyState) {
        case 'DB01':
          return const Color(0xFFB3E8F0); // 맑음
        case 'DB02':
          return const Color(0xFFBAF1FE); // 구름조금
        case 'DB03':
          return const Color(0xFFAEE5F3); // 구름많음
        case 'DB04':
          return const Color(0xFFDDDEDF); // 흐림
      }
    }
    
    // 기본값: 맑음
    return const Color(0xFFB3E8F0);
  }
  
  /// 하늘 상태 코드에 따른 이모지 반환
  /// - DB01: 맑음
  /// - DB02: 구름조금
  /// - DB03: 구름많음
  /// - DB04: 흐림
  static String getSkyStateEmoji(String code) {
    switch (code) {
      case 'DB01':
        return '☀️'; // 맑음
      case 'DB02':
        return '⛅'; // 구름조금
      case 'DB03':
        return '☁️'; // 구름많음
      case 'DB04':
        return '🌥️'; // 흐림
      default:
        return '☀️'; // 기본값: 맑음
    }
  }
  
  /// 하늘 상태 코드에 따른 아이콘 반환 (호환성)
  @Deprecated('Use getSkyStateEmoji instead')
  static IconData getSkyStateIcon(String code) {
    switch (code) {
      case 'DB01':
        return Icons.wb_sunny;
      case 'DB02':
        return Icons.wb_cloudy;
      case 'DB03':
        return Icons.cloud;
      case 'DB04':
        return Icons.cloud_queue;
      default:
        return Icons.wb_sunny;
    }
  }
  
  /// 강수 유무에 따른 아이콘 반환 (int)
  /// - 1: 비
  /// - 2: 비/눈
  /// - 3: 눈
  /// - 4: 소나기
  /// - 5: 빗방울
  /// - 6: 빗방울눈날림
  /// - 7: 눈날림
  static IconData getPrecipitationIcon(int type) {
    switch (type) {
      case 1:
        return Icons.water_drop; // 🌧️ 비
      case 2:
        return Icons.grain; // 🌨️ 비/눈 (혼합)
      case 3:
        return Icons.ac_unit; // ❄️ 눈
      case 4:
        return Icons.thunderstorm; // ⛈️ 소나기
      case 5:
        return Icons.water_drop_outlined; // 💧 빗방울
      case 6:
        return Icons.grain; // 🌨️ 빗방울눈날림
      case 7:
        return Icons.ac_unit_outlined; // ❄️ 눈날림
      default:
        return Icons.water_drop; // 기본값: 비
    }
  }
  
  /// 강수 유무에 따른 이모지 반환 (String)
  static String getPrecipitationEmojiByName(String type) {
    switch (type) {
      case '비':
        return '🌧️'; // 비
      case '비/눈':
        return '🌨️'; // 비/눈 (혼합)
      case '눈':
        return '❄️'; // 눈
      case '소나기':
        return '⛈️'; // 소나기
      case '빗방울':
        return '💧'; // 빗방울
      case '빗방울눈날림':
        return '🌨️'; // 빗방울눈날림
      case '눈날림':
        return '❄️'; // 눈날림
      default:
        return '☀️'; // 기본값: 맑음
    }
  }
  
  /// 강수 유무에 따른 아이콘 반환 (String) - 호환성
  @Deprecated('Use getPrecipitationEmojiByName instead')
  static IconData getPrecipitationIconByName(String type) {
    switch (type) {
      case '비':
        return Icons.water_drop;
      case '비/눈':
        return Icons.grain;
      case '눈':
        return Icons.ac_unit;
      case '소나기':
        return Icons.thunderstorm;
      case '빗방울':
        return Icons.water_drop_outlined;
      case '빗방울눈날림':
        return Icons.grain;
      case '눈날림':
        return Icons.ac_unit_outlined;
      default:
        return Icons.wb_sunny;
    }
  }
  
  /// 하늘 상태 텍스트 반환
  static String getSkyStateText(String code) {
    switch (code) {
      case 'DB01':
        return '맑음';
      case 'DB02':
        return '구름조금';
      case 'DB03':
        return '구름많음';
      case 'DB04':
        return '흐림';
      default:
        return '맑음';
    }
  }
  
  /// 강수 유무 텍스트 반환
  static String getPrecipitationText(int type) {
    switch (type) {
      case 1:
        return '비';
      case 2:
        return '비/눈';
      case 3:
        return '눈';
      case 4:
        return '소나기';
      case 5:
        return '빗방울';
      case 6:
        return '빗방울눈날림';
      case 7:
        return '눈날림';
      default:
        return '';
    }
  }
  

  /// 미세먼지 농도에 따른 아이콘 반환 (Filled)
  static IconData getFineDustIcon(int concentration) {
    if (concentration <= 30) {
      return Icons.sentiment_very_satisfied; // 😄 좋음
    } else if (concentration <= 80) {
      return Icons.sentiment_satisfied; // 🙂 보통
    } else if (concentration <= 120) {
      return Icons.sentiment_neutral; // 😐 약간 나쁨
    } else if (concentration <= 200) {
      return Icons.sentiment_dissatisfied; // 🙁 나쁨
    } else {
      return Icons.sentiment_very_dissatisfied; // 😫 매우 나쁨
    }
  }
  
  /// 미세먼지 농도에 따른 아이콘 반환 (Outlined)
  static IconData getFineDustIconOutlined(int concentration) {
    if (concentration <= 30) {
      return Icons.sentiment_very_satisfied_outlined; // 😄 좋음
    } else if (concentration <= 80) {
      return Icons.sentiment_satisfied_outlined; // 🙂 보통
    } else if (concentration <= 120) {
      return Icons.sentiment_neutral_outlined; // 😐 약간 나쁨
    } else if (concentration <= 200) {
      return Icons.sentiment_dissatisfied_outlined; // 🙁 나쁨
    } else {
      return Icons.sentiment_very_dissatisfied_outlined; // 😫 매우 나쁨
    }
  }

  /// 미세먼지 농도에 따른 색상 반환
  static Color getFineDustColor(int concentration) {
    if (concentration <= 30) {
      return const Color(0xFF00BFFF); // 좋음: 하늘색
    } else if (concentration <= 80) {
      return const Color(0xFF32CD32); // 보통: 라임그린
    } else if (concentration <= 120) {
      return const Color(0xFFFFA500); // 약간 나쁨: 주황색
    } else if (concentration <= 200) {
      return const Color(0xFFFF6600); // 나쁨: 진한 주황색
    } else {
      return const Color(0xFFFF0000); // 매우 나쁨: 빨간색
    }
  }

  /// 미세먼지 농도에 따른 레벨 텍스트 반환
  static String getFineDustLevelText(int concentration) {
    if (concentration <= 30) {
      return '좋음';
    } else if (concentration <= 80) {
      return '보통';
    } else if (concentration <= 120) {
      return '약간나쁨';
    } else if (concentration <= 200) {
      return '나쁨';
    } else {
      return '매우나쁨';
    }
  }

  /// 자외선 지수에 따른 색상 반환
  static Color getUvColor(int index) {
    if (index <= 2) {
      return const Color(0xFFA8E000); // 낮음: 연두색
    } else if (index <= 5) {
      return const Color(0xFFFFD600); // 보통: 노란색
    } else if (index <= 7) {
      return const Color(0xFFFF9F00); // 높음: 주황색
    } else if (index <= 10) {
      return const Color(0xFFFF5F00); // 매우 높음: 진한 주황색
    } else {
      return const Color(0xFFA000C8); // 위험: 보라색
    }
  }

  /// 자외선 지수에 따른 레벨 텍스트 반환
  static String getUvLevelText(int index) {
    if (index <= 2) {
      return '낮음';
    } else if (index <= 5) {
      return '보통';
    } else if (index <= 7) {
      return '높음';
    } else if (index <= 10) {
      return '매우높음';
    } else {
      return '위험';
    }
  }

  /// 강수확률에 따른 색상 반환
  static Color getRainColor(int probability) {
    if (probability <= 20) {
      return const Color(0xFF66D9FF); // 0-20%: 밝은 파란색
    } else if (probability <= 40) {
      return const Color(0xFF33C4FF); // 21-40%: 중간 밝은 파란색
    } else if (probability <= 60) {
      return const Color(0xFF0099FF); // 41-60%: 파란색
    } else if (probability <= 80) {
      return const Color(0xFF007BFF); // 61-80%: 진한 파란색
    } else {
      return const Color(0xFF004C99); // 81-100%: 매우 진한 파란색
    }
  }
}

