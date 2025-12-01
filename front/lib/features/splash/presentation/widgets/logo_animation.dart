import 'package:flutter/material.dart';

class LogoAnimation extends StatelessWidget {
  final AnimationController logoCtrl;
  final Animation<double> logoScale;
  final Animation<double> logoOpacity;
  final Animation<double> logoDy;

  const LogoAnimation({
    super.key,
    required this.logoCtrl,
    required this.logoScale,
    required this.logoOpacity,
    required this.logoDy,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Positioned(
      top: size.height * 0.22,
      child: AnimatedBuilder(
        animation: logoCtrl,
        builder: (_, __) {
          return Opacity(
            opacity: logoOpacity.value,
            child: Transform.translate(
              offset: Offset(0, -logoDy.value), // 위로 이동
              child: Transform.scale(
                scale: logoScale.value,
                child: Image.asset(
                  'assets/images/logo_tonedfit.png',
                  height: 80, // 크기 증가 (52 → 80)
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
