import 'package:flutter/material.dart';
import '../../domain/entities/chat_product.dart';
import 'product_card.dart';

/// 챗봇 상품 그리드
class ChatProductGrid extends StatelessWidget {
  final List<ChatProduct> products;

  const ChatProductGrid({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth, // 부모 너비에 맞춤
          height: 250, // 카드 높이 고정 (240 → 250, +10px)
          child: ListView.separated(
            scrollDirection: Axis.horizontal, // 가로 스크롤
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5), // 상하 패딩 추가
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => SizedBox(
              width: 140, // 카드 너비 고정
              height: 240, // 카드 높이 유지
              child: ChatProductCard(product: products[i]),
            ),
          ),
        );
      },
    );
  }
}

