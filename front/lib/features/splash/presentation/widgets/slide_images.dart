import 'package:flutter/material.dart';

class SlideImages extends StatelessWidget {
  final AnimationController slideCtrl;

  const SlideImages({
    super.key,
    required this.slideCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Positioned(
      top: size.height * 0.4, // 더 위로 배치
      child: AnimatedBuilder(
        animation: slideCtrl,
        builder: (_, __) {
          // 이미지 너비 (화면 너비의 0.8배)
          final imageWidth = size.width * 0.8;
          // 간격 없이 붙여서 나오도록 설정
          final offset = (slideCtrl.value * imageWidth) % imageWidth;

          return Transform.translate(
            offset: Offset(-offset, 0),
            child: Row(
              children: [
                // 첫 번째 이미지
                Image.asset(
                  'assets/images/outfit_all.png',
                  width: imageWidth,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                // 두 번째 이미지 (간격 없이 바로 붙임)
                Image.asset(
                  'assets/images/outfit_all.png',
                  width: imageWidth,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                // 세 번째 이미지 (더 연속적으로)
                Image.asset(
                  'assets/images/outfit_all.png',
                  width: imageWidth,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
