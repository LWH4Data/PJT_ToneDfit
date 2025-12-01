import 'package:flutter/material.dart';

/// 날씨 테마 - 날씨 카드와 모달의 배경색 관리
class WeatherTheme {
  /// 날씨 배경 그라데이션
  /// 날씨 카드와 모달에서 공통으로 사용
  static const LinearGradient weatherGradient = LinearGradient(
    begin: Alignment(0.50, 0.00),
    end: Alignment(0.50, 1.00),
    colors: [
      Color(0xFF4C98EA),  // 진한 파랑
      Color(0xFFB8DDF0),  // 중간 파랑
      Color(0xFFDEEFF8),  // 연한 파랑
    ],
  );

  /// 날씨별 그라데이션 (나중에 사용)
  static const Map<String, LinearGradient> weatherGradients = {
    '맑음': LinearGradient(
      begin: Alignment(0.50, 0.00),
      end: Alignment(0.50, 1.00),
      colors: [
        Color(0xFF4C98EA),
        Color(0xFFB8DDF0),
        Color(0xFFDEEFF8),
      ],
    ),
    '흐림': LinearGradient(
      begin: Alignment(0.50, 0.00),
      end: Alignment(0.50, 1.00),
      colors: [
        Color(0xFF8E8E93),
        Color(0xFFC7C7CC),
        Color(0xFFE5E5EA),
      ],
    ),
    '비': LinearGradient(
      begin: Alignment(0.50, 0.00),
      end: Alignment(0.50, 1.00),
      colors: [
        Color(0xFF5E6D77),
        Color(0xFF9BA9B3),
        Color(0xFFD1D9DD),
      ],
    ),
  };

  /// 날씨에 따른 그라데이션 가져오기
  static LinearGradient getGradientByWeather(String weather) {
    return weatherGradients[weather] ?? weatherGradient;
  }
  
  /// 날씨 배경에 따른 텍스트 색상 가져오기
  /// 밝은 배경 → 검은색, 어두운 배경 → 흰색
  static Color getTextColorByWeather(String weather) {
    // 흐림: 밝은 회색 배경 → 검은색 텍스트
    if (weather == '흐림' || weather == '구름많음') {
      return const Color(0xFF292D32);
    }
    // 비, 눈, 소나기 등: 어두운 배경 → 흰색 텍스트
    else if (weather.contains('비') || weather.contains('눈') || weather.contains('소나기')) {
      return Colors.white;
    }
    // 맑음 및 기타: 파란색 배경 → 흰색 텍스트가 더 잘 보임
    else {
      return Colors.white;
    }
  }
}

