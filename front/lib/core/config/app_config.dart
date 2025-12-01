import 'package:flutter/foundation.dart';

/// 앱 설정
class AppConfig {
  // REST API 설정 (Spring Boot)
  static String get apiBaseUrl {
    if (kDebugMode) {
      // 개발 환경
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://localhost:8000/api',
      );
    } else {
      // 프로덕션 환경
      return const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://k13b105.p.ssafy.io/api',
      );
    }
  }

  // FastAPI 설정 (AI Server)
  static String get aiBaseUrl {
    if (kDebugMode) {
      // 개발 환경
      return const String.fromEnvironment(
        'AI_BASE_URL',
        defaultValue: 'http://localhost:8000/ai',
      );
    } else {
      // 프로덕션 환경
      return const String.fromEnvironment(
        'AI_BASE_URL',
        defaultValue: 'https://k13b105.p.ssafy.io/ai',
      );
    }
  }

  // API 버전
  static const String apiVersion = 'v1';

  // 타임아웃 설정
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 페이지네이션 설정
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // 캐시 설정
  static const Duration cacheExpiration = Duration(hours: 1);

  // 로깅 설정
  static bool get enableLogging => kDebugMode;

  // 앱 정보
  static const String appName = 'Fashion App';
  static const String appVersion = '1.0.0';

  // 환경 확인
  static bool get isProduction => !kDebugMode;
  static bool get isDevelopment => kDebugMode;
}

