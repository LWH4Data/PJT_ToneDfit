import 'package:flutter/material.dart';
import '../../../app/router/app_router.dart';

/// 챗봇 플로팅 버튼 위젯
class ChatbotButton extends StatelessWidget {
  final VoidCallback? onTap;

  const ChatbotButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        // 챗봇 페이지로 이동
        Navigator.pushNamed(context, AppRouter.chatbot);
      },
      child: SizedBox(
        width: 60, // 50 → 60으로 증가
        height: 60, // 50 → 60으로 증가
        child: Image.asset(
          'assets/icons/chat-icon.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

