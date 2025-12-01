import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../cloth/domain/entities/cloth_entity.dart';
import '../../../cloth/data/remote/cloth_api_service.dart';

/// 이미지 검색 API 서비스
class ImageSearchApiService {
  final AiDioClient _aiDioClient = AiDioClient();
  final ClothApiService _clothApiService = ClothApiService();

  /// 이미지로 상품 검색
  Future<List<ClothEntity>> searchByImage(Uint8List imageData) async {
    try {
      // 이미지 압축 (최대 800px, 품질 85%)
      final compressedData = await FlutterImageCompress.compressWithList(
        imageData,
        minWidth: 800,
        minHeight: 800,
        quality: 85,
        format: CompressFormat.jpeg,
      );
      
      print('🖼️ [이미지 검색] 원본 크기: ${(imageData.length / 1024).toStringAsFixed(2)} KB');
      print('🖼️ [이미지 검색] 압축 후 크기: ${(compressedData.length / 1024).toStringAsFixed(2)} KB');
      
      // 압축된 이미지를 MultipartFile로 변환
      final multipartFile = MultipartFile.fromBytes(
        compressedData,
        filename: 'search_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      // FormData 생성 (서버는 'file' 필드를 기대함)
      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      // POST 요청
      print('🖼️ [이미지 검색] API 요청 시작: ${ApiEndpoints.aiSearchImage}');
      print('🖼️ [이미지 검색] Request Body:');
      print('  - Content-Type: multipart/form-data');
      print('  - 필드명: file');
      print('  - 파일명: search_image.jpg');
      print('  - MIME 타입: image/jpeg');
      print('  - 파일 크기: ${compressedData.length} bytes (${(compressedData.length / 1024).toStringAsFixed(2)} KB)');
      
      final response = await _aiDioClient.post(
        ApiEndpoints.aiSearchImage,
        data: formData,
      );
      
      print('🖼️ [이미지 검색] API 응답 수신 완료 (상태 코드: ${response.statusCode})');

      // 응답 파싱
      final data = response.data;
      
      print('🖼️ [이미지 검색] 응답 타입: ${data.runtimeType}');
      
      // 응답 형식: {timestamp, total, results: [...]}
      List<dynamic> productsJson;
      if (data is Map) {
        final total = data['total'] ?? 0;
        print('🖼️ [이미지 검색] 총 결과: $total개');
        
        if (data.containsKey('results')) {
          productsJson = data['results'] as List<dynamic>;
        } else if (data.containsKey('products')) {
          // fallback: products 필드도 체크
          productsJson = data['products'] as List<dynamic>;
        } else {
          print('⚠️ [이미지 검색] results 필드 없음: $data');
          productsJson = [];
        }
      } else if (data is List) {
        productsJson = data;
      } else {
        print('⚠️ [이미지 검색] 예상치 못한 응답 형식: $data');
        productsJson = [];
      }
      
      print('🖼️ [이미지 검색] 검색 결과: ${productsJson.length}개');

      // ClothEntity로 변환
      // API 응답: {product_id, score, product_url, name, brand, gender, 
      //           large_category, small_category, colors, fabrics, sizes, 
      //           original_price, representative_image_url}
      return productsJson
          .map((json) => _clothApiService.clothFromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ [이미지 검색] DioException 발생: ${e.type}');
      print('❌ [이미지 검색] 메시지: ${e.message}');
      print('❌ [이미지 검색] 응답: ${e.response?.data}');
      throw ApiException.fromDioException(e);
    } catch (e) {
      print('❌ [이미지 검색] 예외 발생: $e');
      throw ApiException(
        message: '이미지 검색 중 오류가 발생했습니다: $e',
        statusCode: -1,
      );
    }
  }
}

