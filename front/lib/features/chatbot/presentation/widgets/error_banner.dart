import 'package:flutter/material.dart';

/// 챗봇 에러 메시지 배너
class ErrorBanner extends StatelessWidget {
  final String text;

  const ErrorBanner({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8D7DA),
        border: Border.all(color: const Color(0xFFF5C2C7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB02A37), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF842029), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

