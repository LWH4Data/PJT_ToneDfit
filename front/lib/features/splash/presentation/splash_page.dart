import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/start_button.dart';
import 'widgets/logo_animation.dart';
import 'widgets/slide_images.dart';
import 'widgets/splash_text.dart';
import 'widgets/loading_indicator.dart';
import 'providers/splash_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoDy; // 아래→위로 약간 이동
  late final AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();

    // 로고: 작게 시작 → 커지면서(Scale) + 살짝 위로(Translate) + 페이드인
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn));
    _logoDy = Tween<double>(
      begin: 16.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));

    // 0.5초 뒤에 로고 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 500), _logoCtrl.forward);

    // 코디 이미지 좌→우 무한 슬라이드
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // 속도 증가 (12초 → 6초)
    )..repeat();

    // 데이터 로딩 시작 (Riverpod 사용)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(splashProvider.notifier).loadMainPageData();
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final splashState = ref.watch(splashProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 투명하게 해서 배경 이미지 색상 그대로 사용
        statusBarIconBrightness: Brightness.dark, // 아이콘 어둡게 (밝은 배경용)
      ),
      child: Scaffold(
        backgroundColor: Colors.white, // 배경색 추가 (이미지 로드 실패 대비)
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 상단 문구
          const SplashText(),

          // 로고 애니메이션
          LogoAnimation(
            logoCtrl: _logoCtrl,
            logoScale: _logoScale,
            logoOpacity: _logoOpacity,
            logoDy: _logoDy,
          ),

          // 슬라이드 이미지
          SlideImages(slideCtrl: _slideCtrl),
          
          // 로딩 인디케이터 또는 시작하기 버튼
          if (splashState.isLoading)
            LoadingIndicator(message: splashState.loadingMessage)
          else if (splashState.isDataLoaded)
            const StartButton(),
        ],
        ),
      ),
    );
  }
}
