import 'package:flutter/material.dart';

// Design Tokens - 공통 디자인 토큰 정의
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFCF6A7);
  static const Color primaryDark = Color(0xFF292D32);
  
  // Brand Colors
  static const Color brandAccent = Color(0xFFFB4A6E); // 톤디핏 브랜드 컬러 (핑크)
  static const Color aiText = Color(0xFFAF12C4); // AI 텍스트 컬러
  
  // UI Active Colors
  static const Color activeColor = Color(0xFF476A62); // 활성화/선택 상태 색상 (청록색)
  static const Color borderColor = Color(0xFF9AA6B2); // 기본 테두리 색상 (회색)
  
  // Rank Change Colors
  static const Color rankUp = Color(0xFFFB4A6E); // 순위 상승 (핑크)
  static const Color rankDown = Color(0xFF476A62); // 순위 감소 (청록색)
  static const Color rankNew = Color(0xFFFFA726); // 신규 (주황색)
  
  // Gradient Colors
  static const Color gradientHeader = Color(0xFFD9D9D9); // 헤더 그라데이션 시작
  static const Color gradientHeaderEnd = Color(0xFFA4CDF5); // 헤더 그라데이션 끝
  
  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF292D32);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 100.0;
}

class AppTypography {
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
  static const double fontSizeXl = 20.0;
  static const double fontSizeXxl = 24.0;
  static const double fontSizeXxxl = 32.0;
  
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
}

class AppSizes {
  // Button Sizes
  static const double buttonHeight = 54.0;
  static const double buttonWidth = 344.0;
  
  // Image Sizes
  static const double logoHeight = 80.0;
  static const double slideImageHeight = 80.0;
}
