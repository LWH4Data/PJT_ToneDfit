import '../entities/cloth_entity.dart';

/// 상품 필터 검색 응답 모델
class ProductFilterResponse {
  final int total;
  final int page;
  final int size;
  final List<ClothEntity> products;

  const ProductFilterResponse({
    required this.total,
    required this.page,
    required this.size,
    required this.products,
  });

  /// 다음 페이지가 있는지 확인
  bool get hasNextPage => page * size < total;

  /// 총 페이지 수
  int get totalPages => (total / size).ceil();

  /// 현재 페이지의 시작 인덱스
  int get startIndex => (page - 1) * size + 1;

  /// 현재 페이지의 끝 인덱스
  int get endIndex => (page * size < total) ? page * size : total;

  factory ProductFilterResponse.fromJson(Map<String, dynamic> json, List<ClothEntity> products) {
    return ProductFilterResponse(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 20,
      products: products,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'size': size,
      'products': products.length,
    };
  }
}

