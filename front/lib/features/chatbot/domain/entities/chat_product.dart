/// 챗봇 응답 상품 엔티티
class ChatProduct {
  final String representativeImageUrl;
  final String brand;
  final String name;
  final num originalPrice;
  final String productUrl; // 상품 URL 추가

  ChatProduct({
    required this.representativeImageUrl,
    required this.brand,
    required this.name,
    required this.originalPrice,
    required this.productUrl,
  });

  factory ChatProduct.fromJson(Map<String, dynamic> json) {
    return ChatProduct(
      representativeImageUrl: (json['representative_image_url'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      originalPrice: json['original_price'] ?? 0,
      productUrl: (json['product_url'] ?? '').toString(),
    );
  }
}

