/// 앱 전역 상수
class AppConstants {
  // 레이아웃 관련 상수
  static const double headerHeight = 93.0;
  static const double bottomNavHeight = 85.0;
  static const double defaultPadding = 20.0;
  
  // 날씨 카드 관련 상수
  static const double weatherCardInitialTop = 60.0; // 위로 올림 (83 → 60)
  static const double weatherCardOverlap = 10.0; // 헤더와 겹치는 정도
  static const double weatherCardBorderRadius = 20.0;
  static const double weatherCardSpacing = 70.0; // 날씨 카드와 상품 정보 간격
  
  // 대분류 태그 관련 상수
  static const double categoryTagOpacity = 0.7; // 평상시 투명도
  static const double categoryTagBottomOffset = 145.0; // 하단에서의 거리
  
  // 타이머 관련 상수
  static const Duration characterChangeDuration = Duration(minutes: 10);
  
  // 캐릭터 이미지 경로
  static const List<String> characterImages = [
    'assets/character/example/cody1.png',
    'assets/character/example/cody2.png',
    'assets/character/example/cody3.png',
    'assets/character/example/cody4.png',
    'assets/character/example/cody5.png',
    'assets/character/example/cody6.png',
  ];
  
  // 애니메이션 관련 상수
  static const Duration modalAnimationDuration = Duration(milliseconds: 400);
  static const Duration buttonAnimationDuration = Duration(milliseconds: 150);
}

