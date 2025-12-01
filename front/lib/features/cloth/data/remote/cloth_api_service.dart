import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/cloth_entity.dart';
import '../../domain/models/product_filter_response.dart';
import '../category_data.dart';

/// 상품(옷) API 서비스
class ClothApiService {
  final AiDioClient _aiDioClient = AiDioClient(); // FastAPI용 클라이언트

  /// FastAPI - 필터 기반 상품 검색
  Future<ProductFilterResponse> filterProducts({
    num? apparentTemp, // double 또는 int 모두 허용
    String? query,
    List<String>? brands,
    String? gender,
    String? largeCategory,
    String? smallCategory,
    int? minPrice,
    int? maxPrice,
    List<String>? fabrics,
    List<String>? colors,
    List<String>? sizes,
    int? page, // 선택적 파라미터로 변경
    int? pageSize, // 선택적 파라미터로 변경
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (apparentTemp != null) 'apparentTemp': apparentTemp.round(), // 정수로 반올림
        if (query != null) 'query': query,
        if (brands != null && brands.isNotEmpty) 'brand': brands.join(','),
        if (gender != null) 'gender': gender,
        if (largeCategory != null) 'largeCategory': largeCategory,
        if (smallCategory != null) 'smallCategory': smallCategory,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (fabrics != null && fabrics.isNotEmpty) 'fabric': fabrics.join(','),
        if (colors != null && colors.isNotEmpty) 'color': colors.join(','),
        if (sizes != null && sizes.isNotEmpty) 'size': sizes.join(','),
        if (page != null) 'page': page, // null이 아닐 때만 추가
        if (pageSize != null) 'pageSize': pageSize, // null이 아닐 때만 추가
      };

      final response = await _aiDioClient.get(
        ApiEndpoints.aiProductsFilter,
        queryParameters: queryParameters,
      );

      final data = response.data as Map<String, dynamic>;
      final List<dynamic> productsJson = data['products'] ?? [];
      final products = productsJson.map((json) => clothFromJson(json)).toList();

      return ProductFilterResponse.fromJson(data, products);
    } on DioException catch (e) {
      // 404 에러는 "상품 없음"을 의미하므로 빈 결과로 반환
      if (e.response?.statusCode == 404) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData['detail'] != null) {
          // "No products found matching the given filters" 같은 경우
          return ProductFilterResponse(
            total: 0,
            page: page ?? 1,
            size: pageSize ?? 20,
            products: [],
          );
        }
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException(
        message: '상품 검색 중 오류가 발생했습니다.',
        statusCode: null,
        data: null,
      );
    }
  }

  // ============================================
  // REST API 메서드들 (현재 미사용 - 엔드포인트 추가 후 주석 해제)
  // ============================================

  // /// 모든 상품 조회
  // Future<List<ClothEntity>> getProducts({
  //   int page = 1,
  //   int limit = 20,
  //   String? search,
  //   String? genderId,
  //   String? largeCategoryId,
  //   String? smallCategoryId,
  // }) async {
  //   try {
  //     final queryParameters = <String, dynamic>{
  //       'page': page,
  //       'limit': limit,
  //       if (search != null) 'search': search,
  //       if (genderId != null) 'gender_id': genderId,
  //       if (largeCategoryId != null) 'large_category_id': largeCategoryId,
  //       if (smallCategoryId != null) 'small_category_id': smallCategoryId,
  //     };
  //
  //     final response = await _dioClient.get(
  //       ApiEndpoints.products,
  //       queryParameters: queryParameters,
  //     );
  //
  //     final List<dynamic> data = response.data['data'] ?? response.data;
  //     return data.map((json) => _clothFromJson(json)).toList();
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioException(e);
  //   }
  // }

  // /// 특정 상품 조회
  // Future<ClothEntity> getProductById(String productId) async {
  //   try {
  //     final response = await _dioClient.get(
  //       ApiEndpoints.productById(productId),
  //     );
  //
  //     return _clothFromJson(response.data['data'] ?? response.data);
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioException(e);
  //   }
  // }

  // /// 상품 검색
  // Future<List<ClothEntity>> searchProducts({
  //   required String query,
  //   int page = 1,
  //   int limit = 20,
  //   String? genderId,
  //   String? largeCategoryId,
  //   String? smallCategoryId,
  //   int? minPrice,
  //   int? maxPrice,
  //   List<String>? colors,
  // }) async {
  //   try {
  //     final queryParameters = <String, dynamic>{
  //       'q': query,
  //       'page': page,
  //       'limit': limit,
  //       if (genderId != null) 'gender_id': genderId,
  //       if (largeCategoryId != null) 'large_category_id': largeCategoryId,
  //       if (smallCategoryId != null) 'small_category_id': smallCategoryId,
  //       if (minPrice != null) 'min_price': minPrice,
  //       if (maxPrice != null) 'max_price': maxPrice,
  //       if (colors != null && colors.isNotEmpty) 'colors': colors.join(','),
  //     };
  //
  //     final response = await _dioClient.get(
  //       ApiEndpoints.productsSearch,
  //       queryParameters: queryParameters,
  //     );
  //
  //     final List<dynamic> data = response.data['data'] ?? response.data;
  //     return data.map((json) => _clothFromJson(json)).toList();
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioException(e);
  //   }
  // }

  // /// 카테고리별 상품 조회
  // Future<List<ClothEntity>> getProductsByCategory({
  //   required String categoryId,
  //   int page = 1,
  //   int limit = 20,
  // }) async {
  //   try {
  //     final response = await _dioClient.get(
  //       ApiEndpoints.productsByCategory(categoryId),
  //       queryParameters: {
  //         'page': page,
  //         'limit': limit,
  //       },
  //     );
  //
  //     final List<dynamic> data = response.data['data'] ?? response.data;
  //     return data.map((json) => _clothFromJson(json)).toList();
  //   } on DioException catch (e) {
  //     throw ApiException.fromDioException(e);
  //   }
  // }

  /// JSON을 ClothEntity로 변환 (public으로 변경하여 다른 서비스에서도 사용 가능)
  ClothEntity clothFromJson(Map<String, dynamic> json) {
    return ClothEntity(
      productId: json['productId']?.toString() ?? 
                 json['product_id']?.toString() ?? 
                 json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      representativeImageUrl: json['representativeImageUrl']?.toString() ?? 
                              json['representative_image_url']?.toString() ?? 
                              json['image_url']?.toString() ?? 
                              'https://placehold.co/130x95',
      originalPrice: json['originalPrice'] as int? ?? 
                     json['original_price'] as int? ?? 
                     json['price'] as int? ?? 
                     0,
      colors: (json['colors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      fabrics: (json['fabrics'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sizes: (json['sizes'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      reviewsCount: json['reviews_count'] as int? ?? json['reviewsCount'] as int? ?? 0,
      productUrl: json['productUrl']?.toString() ?? 
                  json['product_url']?.toString() ?? 
                  '',
      smallCategoryId: _getSmallCategoryId(json),
      gender: json['gender']?.toString(),
      largeCategory: json['largeCategory']?.toString() ?? json['large_category']?.toString(),
      smallCategory: json['smallCategory']?.toString() ?? json['small_category']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : (json['created_at'] != null 
              ? DateTime.parse(json['created_at'].toString())
              : DateTime.now()),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString())
          : (json['updated_at'] != null 
              ? DateTime.parse(json['updated_at'].toString())
              : DateTime.now()),
    );
  }

  /// smallCategoryId 추출 헬퍼 메서드
  String _getSmallCategoryId(Map<String, dynamic> json) {
    // 1. ID 직접 전달된 경우
    final directId = json['small_category_id']?.toString() ?? 
                     json['smallCategoryId']?.toString() ?? 
                     json['category_id']?.toString();
    
    if (directId != null && directId.isNotEmpty) {
      return directId;
    }
    
    // 2. 이름으로 ID 찾기
    final smallCategoryName = json['smallCategory']?.toString() ?? 
                              json['small_category']?.toString();
    
    if (smallCategoryName != null && smallCategoryName.isNotEmpty) {
      final id = CategoryData.findSmallCategoryIdByName(smallCategoryName);
      if (id != null) {
        return id;
      }
    }
    
    return ''; // 기본값
  }
}

