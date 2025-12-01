import 'package:flutter/material.dart';
import '../../app/router/app_router.dart';

/// 하단 네비게이션 공통 로직
class NavigationHelper {
  /// 하단 네비게이션 탭 처리 (공통)
  static void handleBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.weather);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.category);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRouter.profile);
        break;
    }
  }
}

