import 'package:flutter/material.dart';
import '../../domain/entities/chat_product.dart';
import '../../../cloth/presentation/pages/product_webview_page.dart';

/// 챗봇 상품 카드
class ChatProductCard extends StatelessWidget {
  final ChatProduct product;

  const ChatProductCard({
    super.key,
    required this.product,
  });

  String _formatPrice(num n) {
    final s = n.toString();
    final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return s.replaceAllMapped(reg, (m) => ',');
  }
  
  void _openProductUrl(BuildContext context) {
    if (product.productUrl.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductWebViewPage(
          url: product.productUrl,
          title: product.name, // 상품명을 title로 전달
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openProductUrl(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            SizedBox(
              height: 140, // 200 → 140 (70%)
              width: double.infinity,
              child: Image.network(
                product.representativeImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF0F0F0),
                  alignment: Alignment.center,
                  child: const Text(
                    'No Image',
                    style: TextStyle(color: Color(0xFF999999)),
                  ),
                ),
              ),
            ),
            // 상품 정보
            SizedBox(
              height: 100, // 고정 높이 (240 - 140 = 100)
              child: Padding(
                padding: const EdgeInsets.all(8), // 12 → 8로 축소
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: const TextStyle(
                        fontSize: 10, // 12 → 10
                        color: Color(0xFF6C757D),
                      ),
                    ),
                    const SizedBox(height: 2), // 4 → 2
                    Tooltip(
                      message: product.name,
                      child: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12, // 14 → 12
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${_formatPrice(product.originalPrice)}원',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12, // 14 → 12
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFB4A6E), // 브랜드 컬러
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () => _openProductUrl(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, // 8 → 6
                              vertical: 3, // 4 → 3
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: const Color(0xFFFB4A6E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            '상품 보기',
                            style: TextStyle(fontSize: 9), // 10 → 9
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

