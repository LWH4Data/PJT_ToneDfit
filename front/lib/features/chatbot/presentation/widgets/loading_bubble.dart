import 'package:flutter/material.dart';

/// 챗봇 로딩 애니메이션 (점 3개)
class LoadingBubble extends StatefulWidget {
  const LoadingBubble({super.key});

  @override
  State<LoadingBubble> createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<LoadingBubble>
    with TickerProviderStateMixin {
  late final AnimationController c1;
  late final AnimationController c2;
  late final AnimationController c3;

  @override
  void initState() {
    super.initState();
    c1 = _controller();
    c2 = _controller(delay: 150);
    c3 = _controller(delay: 300);
    c1.repeat();
    c2.repeat();
    c3.repeat();
  }

  AnimationController _controller({int delay = 0}) {
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (delay > 0) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) ctrl.forward(from: 0);
      });
    }
    return ctrl;
  }

  @override
  void dispose() {
    c1.dispose();
    c2.dispose();
    c3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget dot(AnimationController c) => FadeTransition(
          opacity: Tween(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: c, curve: Curves.easeInOut),
          ),
          child: const SizedBox(
            width: 8,
            height: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFB4A6E), // 브랜드 컬러
              ),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot(c1),
          const SizedBox(width: 6),
          dot(c2),
          const SizedBox(width: 6),
          dot(c3),
        ],
      ),
    );
  }
}

