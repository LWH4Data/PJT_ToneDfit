import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import 'product_grid.dart';

/// 챗봇 메시지 타일
class MessageTile extends StatelessWidget {
  final ChatMessage message;

  const MessageTile({
    super.key,
    required this.message,
  });

  String _formatKo(DateTime dt) {
    return '${dt.year}.${_two(dt.month)}.${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 상품 카드가 있으면 말풍선을 더 크게 (80%), 없으면 75%
    // 봇 메시지는 아이콘(10%) + 패딩(8px)을 고려해야 함
    final hasProducts = message.products != null && message.products!.isNotEmpty;
    final maxBubbleWidth = screenWidth * (hasProducts ? 0.80 : 0.75);
    
    final isUser = message.sender == Sender.user;
    final bubbleColor = isUser
        ? const LinearGradient(
            colors: [Color(0xFFFB4A6E), Color(0xFFE91E63)], // 브랜드 컬러
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;
    final bubbleBg = isUser ? null : Colors.white;
    final bubbleTextColor = isUser ? Colors.white : Colors.black87;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: maxBubbleWidth,
      ),
      padding: EdgeInsets.fromLTRB(
        hasProducts ? 12 : 12, // left
        hasProducts ? 12 : 12, // top
        hasProducts ? 12 : 12, // right
        hasProducts ? 16 : 12, // bottom - 상품 있을 때 하단 패딩 증가
      ),
      decoration: BoxDecoration(
        color: bubbleBg,
        gradient: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 6),
          bottomRight: Radius.circular(isUser ? 6 : 18),
        ),
        boxShadow: isUser
            ? null
            : const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ],
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상품 그리드 (봇 메시지일 때만, 말풍선 안에 먼저 표시)
          if (!isUser && message.products != null && message.products!.isNotEmpty) ...[
            ChatProductGrid(products: message.products!),
            const SizedBox(height: 20),
          ],
          // 텍스트 메시지
          Text(
            message.text, // HTML escape/unescape 제거 - 원본 그대로 표시
            style: TextStyle(color: bubbleTextColor, height: 1.4),
          ),
          if (message.timestamp != null) ...[
            const SizedBox(height: 6),
            Text(
              _formatKo(message.timestamp!),
              style: TextStyle(
                fontSize: 11,
                color: isUser ? Colors.white70 : const Color(0xFF6C757D),
              ),
            ),
          ],
        ],
      ),
    );

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        // 말풍선 (상품 카드 포함)
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 봇 메시지일 때만 챗봇 아이콘 표시
            if (!isUser) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 8),
                child: SizedBox(
                  width: screenWidth * 0.10, // 화면 너비의 10% (390 기준 39px)
                  height: screenWidth * 0.10,
                  child: Image.asset(
                    'assets/icons/chatbot-icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
            Flexible(child: bubble),
          ],
        ),
      ],
    );
  }
}

