// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'app/di/app_di.dart';
import 'firebase_options.dart';

/// 스크롤바를 숨기는 커스텀 ScrollBehavior
class NoScrollbarBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // 스크롤바를 렌더링하지 않음
    return child;
  }
}

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // 네이티브 스플래시 보존
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // DI 초기화
  await AppDI.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  // 첫 프레임 그려지면 네이티브 스플래시 즉시 제거
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterNativeSplash.remove();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final firebaseAnalytics = FirebaseAnalytics.instance;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TonedFit',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // 다크모드 비활성화
      scrollBehavior: NoScrollbarBehavior(), // 스크롤바 제거
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
      ],
    );
  }
}
