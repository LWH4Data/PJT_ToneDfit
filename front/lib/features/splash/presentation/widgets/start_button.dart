import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class StartButton extends ConsumerWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final authState = ref.watch(authStateProvider);
    
    return Positioned(
      bottom: size.height * 0.15,
      left: (size.width - 344) / 2, // 가운데 정렬
      child: GestureDetector(
        onTap: () {
          // 인증 상태에 따라 분기
          if (authState.isAuthenticated) {
            // 이미 로그인되어 있으면 바로 홈으로
            print('✅ [Splash] 이미 인증됨, 홈으로 이동');
            Navigator.pushReplacementNamed(context, AppRouter.home);
          } else {
            // 로그인되어 있지 않으면 닉네임 입력 페이지로
            print('🔐 [Splash] 미인증, 닉네임 입력으로 이동');
            Navigator.pushReplacementNamed(context, AppRouter.nickname);
          }
        },
        child: Container(
          width: 344,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFFCF6A7),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Center(
            child: Text(
              '시작하기',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF292D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
