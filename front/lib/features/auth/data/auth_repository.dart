import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/secure_storage.dart';

/// 인증 리포지토리
class AuthRepository {
  final DioClient _dioClient = DioClient();
  final SecureStorage _storage;

  AuthRepository(this._storage);

  /// 익명 로그인 (닉네임 선택 또는 건너뛰기)
  Future<Map<String, dynamic>> signInAnonymous({String? nickname}) async {
    try {
      // Request Body
      final body = (nickname == null || nickname.isEmpty) 
          ? <String, dynamic>{}
          : {'nickname': nickname};

      print('🔐 [Auth] 익명 로그인 요청: ${nickname ?? "(닉네임 없음)"}');

      // POST /api/user/create
      final response = await _dioClient.post(
        ApiEndpoints.userCreate,
        data: body,
      );

      final data = response.data as Map<String, dynamic>;
      
      // 응답에서 accessToken이 있으면 저장
      // 주의: 예시 코드와 다르게 응답 구조 확인 필요
      // 예시: { userId, nickname, role, createdAt, lastLoginAt }
      // 토큰은 헤더나 다른 필드에 있을 수 있음
      
      final userId = data['userId']?.toString();
      final userNickname = data['nickname']?.toString();
      
      // 토큰이 응답에 있다면 저장 (실제 응답 구조 확인 후 수정)
      if (data.containsKey('accessToken')) {
        final token = data['accessToken']?.toString();
        if (token != null) {
          await _storage.saveAccessToken(token);
        }
      } else {
        // 토큰이 없으면 userId를 토큰처럼 사용 (임시)
        if (userId != null) {
          await _storage.saveAccessToken(userId);
        }
      }
      
      // 사용자 정보 저장
      if (userId != null) {
        await _storage.saveUserId(userId);
      }
      if (userNickname != null) {
        await _storage.saveNickname(userNickname);
      }

      print('✅ [Auth] 로그인 성공: userId=$userId, nickname=$userNickname');

      return data;
    } on DioException catch (e) {
      print('❌ [Auth] 로그인 실패: ${e.message}');
      throw ApiException.fromDioException(e);
    } catch (e) {
      print('❌ [Auth] 로그인 예외: $e');
      throw ApiException(
        message: '로그인 중 오류가 발생했습니다: $e',
        statusCode: -1,
      );
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _storage.clear();
    print('🔐 [Auth] 로그아웃 완료');
  }
}

