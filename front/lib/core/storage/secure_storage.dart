import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 보안 스토리지 (토큰 저장)
class SecureStorage {
  static const _ACCESS_TOKEN = 'access_token';
  static const _USER_ID = 'user_id';
  static const _NICKNAME = 'nickname';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _ACCESS_TOKEN, value: token);
  }

  /// 액세스 토큰 읽기
  Future<String?> readAccessToken() => _storage.read(key: _ACCESS_TOKEN);

  /// 사용자 ID 저장
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _USER_ID, value: userId);
  }

  /// 사용자 ID 읽기
  Future<String?> readUserId() => _storage.read(key: _USER_ID);

  /// 닉네임 저장
  Future<void> saveNickname(String nickname) async {
    await _storage.write(key: _NICKNAME, value: nickname);
  }

  /// 닉네임 읽기
  Future<String?> readNickname() => _storage.read(key: _NICKNAME);

  /// 모든 데이터 삭제 (로그아웃)
  Future<void> clear() async {
    await _storage.delete(key: _ACCESS_TOKEN);
    await _storage.delete(key: _USER_ID);
    await _storage.delete(key: _NICKNAME);
  }
}

