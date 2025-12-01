import 'package:flutter/material.dart';
import '../../features/splash/index.dart';
import '../../features/home/index.dart';
import '../../features/auth/index.dart';
import '../../features/search/index.dart';
import '../../features/category/index.dart';
import '../../features/profile/index.dart';
import '../../features/weather/presentation/pages/weather_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';

// 앱 라우팅 관리 - 모든 라우팅을 한 곳에서 결선
class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String nickname = '/nickname';
  static const String search = '/search';
  static const String weather = '/weather';
  static const String category = '/category';
  static const String profile = '/profile';
  static const String chatbot = '/chatbot';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case home:
        // 홈과 카테고리 간 전환 시 애니메이션 없이
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          settings: settings,
        );
      case nickname:
        return MaterialPageRoute(
          builder: (_) => const NicknameInputPage(),
          settings: settings,
        );
      case search:
        // 검색 페이지 전환 시 슬라이드 애니메이션 (오른쪽에서 왼쪽으로)
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const SearchPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // 오른쪽에서 왼쪽으로 슬라이드 (진입)
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            // 뒤로 가기 시 (reverse 애니메이션)
            // 왼쪽에서 오른쪽으로 슬라이드
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          settings: settings,
        );
      case weather:
        // 날씨 페이지 전환 시 애니메이션 없이
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const WeatherPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          settings: settings,
        );
      case category:
        // 카테고리 페이지 전환 시 애니메이션 없이
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const CategoryPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          settings: settings,
        );
      case profile:
        // 프로필 페이지 전환 시 애니메이션 없이
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          settings: settings,
        );
      case chatbot:
        // 챗봇 페이지 - 하단에서 슬라이드 업
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const ChatbotPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // 하단에서 시작
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
          settings: settings,
        );
    }
  }
  
  // 네비게이션 헬퍼 메서드들
  static void pushNamed(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
  
  static void pushReplacementNamed(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }
  
  static void pushAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
    );
  }
}
