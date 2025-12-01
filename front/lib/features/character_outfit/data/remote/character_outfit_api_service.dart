import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';

/// 캐릭터 옷 입히기 API 서비스
class CharacterOutfitApiService {
  final AiDioClient _aiDioClient = AiDioClient();

  /// 캐릭터에 옷을 입힌 이미지 생성
  /// 
  /// [garmentImageData] 입힐 의상 이미지 바이트 데이터
  /// 
  /// Returns: 생성된 PNG 이미지 바이트 데이터 (배경 제거된 버전)
  Future<Uint8List> generateCharacterOutfit(Uint8List garmentImageData) async {
    try {
      // 이미지 압축 (최대 1024px, 품질 90%)
      final compressedData = await FlutterImageCompress.compressWithList(
        garmentImageData,
        minWidth: 1024,
        minHeight: 1024,
        quality: 90,
        format: CompressFormat.jpeg,
      );
      
      print('👗 [캐릭터 옷 입히기] 원본 크기: ${(garmentImageData.length / 1024).toStringAsFixed(2)} KB');
      print('👗 [캐릭터 옷 입히기] 압축 후 크기: ${(compressedData.length / 1024).toStringAsFixed(2)} KB');
      
      // 압축된 이미지를 MultipartFile로 변환
      final multipartFile = MultipartFile.fromBytes(
        compressedData,
        filename: 'garment_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );

      // FormData 생성 (서버는 'file' 필드를 기대함)
      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      // POST 요청
      print('👗 [캐릭터 옷 입히기] API 요청 시작: ${ApiEndpoints.aiCharacterOutfitGenerate}');
      print('👗 [캐릭터 옷 입히기] Request Body:');
      print('  - Content-Type: multipart/form-data');
      print('  - 필드명: file');
      print('  - 파일명: garment_image.jpg');
      print('  - MIME 타입: image/jpeg');
      print('  - 파일 크기: ${compressedData.length} bytes (${(compressedData.length / 1024).toStringAsFixed(2)} KB)');
      
      final response = await _aiDioClient.post(
        ApiEndpoints.aiCharacterOutfitGenerate,
        data: formData,
        options: Options(
          responseType: ResponseType.bytes, // 바이너리 응답 받기
          headers: {
            'Accept': 'image/png',
          },
        ),
      );
      
      print('👗 [캐릭터 옷 입히기] API 응답 수신 완료 (상태 코드: ${response.statusCode})');
      print('👗 [캐릭터 옷 입히기] 응답 크기: ${(response.data.length / 1024).toStringAsFixed(2)} KB');

      // 응답이 바이트 배열인지 확인
      if (response.data is! Uint8List && response.data is! List<int>) {
        throw ApiException(
          message: '이미지 데이터 형식이 올바르지 않습니다.',
          statusCode: response.statusCode ?? 500,
        );
      }

      // Uint8List로 변환
      final Uint8List imageBytes = response.data is Uint8List 
          ? response.data 
          : Uint8List.fromList(response.data);
      
      print('👗 [캐릭터 옷 입히기] 이미지 생성 완료');
      return imageBytes;

    } on DioException catch (e) {
      print('❌ [캐릭터 옷 입히기] DioException 발생: ${e.message}');
      print('❌ [캐릭터 옷 입히기] 상태 코드: ${e.response?.statusCode}');
      print('❌ [캐릭터 옷 입히기] 응답 데이터: ${e.response?.data}');
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode ?? 500;
        String message = '이미지 생성에 실패했습니다.';
        
        if (e.response!.data is Map) {
          message = e.response!.data['detail'] ?? message;
        } else if (e.response!.data is String) {
          message = e.response!.data;
        }
        
        throw ApiException(
          message: message,
          statusCode: statusCode,
        );
      } else {
        throw ApiException(
          message: '네트워크 오류가 발생했습니다. 인터넷 연결을 확인해주세요.',
          statusCode: 0,
        );
      }
    } catch (e) {
      print('❌ [캐릭터 옷 입히기] 예외 발생: $e');
      throw ApiException(
        message: '이미지 생성 중 오류가 발생했습니다: $e',
        statusCode: 500,
      );
    }
  }

  /// API 상태 확인
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await _aiDioClient.get('/character-outfit/health');
      return response.data;
    } catch (e) {
      print('❌ [캐릭터 옷 입히기] Health check 실패: $e');
      rethrow;
    }
  }
}
