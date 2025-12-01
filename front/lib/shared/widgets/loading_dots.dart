import 'package:flutter/material.dart';

/// 로딩 점 애니메이션 위젯
class LoadingDots extends StatefulWidget {
  final String? message;
  final Color? dotColor;
  final Color? textColor;
  final double? dotSize;
  final double? fontSize;
  final Widget? icon;

  const LoadingDots({
    super.key,
    this.message = '로딩 중',
    this.dotColor,
    this.textColor,
    this.dotSize = 10.0,
    this.fontSize = 20.0,
    this.icon,
  });

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.dotColor ?? const Color(0xFF292D32);
    final textColor = widget.textColor ?? Colors.black;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아이콘 (선택사항)
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(height: 20),
        ],
        // 로딩 점 애니메이션
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final delay = index * 0.3;
                final value = (_animationController.value + delay) % 1.0;
                final scale = value < 0.5 ? value * 2 : (1 - value) * 2;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Transform.scale(
                    scale: 0.5 + (scale * 0.5),
                    child: Container(
                      width: widget.dotSize,
                      height: widget.dotSize,
                      decoration: ShapeDecoration(
                        color: dotColor,
                        shape: const OvalBorder(),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
        const SizedBox(height: 10),
        // 메시지 텍스트
        if (widget.message != null)
          Text(
            widget.message!,
            style: TextStyle(
              color: textColor,
              fontSize: widget.fontSize,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.20,
              letterSpacing: 0.15,
            ),
          ),
      ],
    );
  }
}

