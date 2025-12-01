/// 상품(옷) 엔티티
class ClothEntity {
  // 기본 정보
  final String productId;
  final String name;
  final String brand;
  final String productUrl;
  
  // 가격 정보
  final int originalPrice;
  
  // 이미지 및 색상
  final String representativeImageUrl;
  final List<String> colors;
  
  // 소재 및 사이즈
  final List<String> fabrics;
  final List<String> sizes;
  
  // 리뷰
  final int reviewsCount;
  
  // 카테고리 정보 (API 응답에서 받음)
  final String? gender; // 성별: "남성", "여성"
  final String? largeCategory; // 대분류: "상의", "아우터", "하의", "원피스/스커트"
  final String? smallCategory; // 소분류: "데님 팬츠", "티셔츠" 등
  final String smallCategoryId; // 소분류 ID (내부 매핑용)
  
  // 메타데이터
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClothEntity({
    required this.productId,
    required this.name,
    required this.brand,
    required this.productUrl,
    required this.originalPrice,
    required this.representativeImageUrl,
    required this.colors,
    required this.fabrics,
    required this.sizes,
    required this.reviewsCount,
    this.gender,
    this.largeCategory,
    this.smallCategory,
    required this.smallCategoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClothEntity && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}


