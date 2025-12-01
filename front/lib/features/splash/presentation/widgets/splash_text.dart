import 'package:flutter/material.dart';

class SplashText extends StatelessWidget {
  const SplashText({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Positioned(
      top: size.height * 0.15,
      child: const Text(
        '오늘의 날씨, 오늘의 옷',
        style: TextStyle(
          fontSize: 18, // 크기 축소 (22 → 18)
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
