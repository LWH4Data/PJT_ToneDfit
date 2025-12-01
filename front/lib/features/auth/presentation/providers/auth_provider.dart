import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/auth_state.dart';
import '../../data/auth_repository.dart';

/// SecureStorage Provider
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(storage);
});

/// AuthState Notifier
class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState.initial;

  void updateState(AuthState newState) {
    state = newState;
  }
}

/// AuthState Provider
final authStateProvider = NotifierProvider<AuthStateNotifier, AuthState>(() {
  return AuthStateNotifier();
});

/// AuthController Provider
final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

/// 앱 초기화 Provider (토큰 유무 확인)
final authInitProvider = FutureProvider<void>((ref) async {
  await ref.read(authControllerProvider).initFromStorage();
});

/// 인증 컨트롤러
class AuthController {
  final Ref ref;

  AuthController(this.ref);

  SecureStorage get _storage => ref.read(secureStorageProvider);
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// 스토리지에서 토큰 로드 (앱 시작 시)
  Future<void> initFromStorage() async {
    print('🔐 [Auth] 초기화 시작...');
    
    final token = await _storage.readAccessToken();
    final userId = await _storage.readUserId();
    final nickname = await _storage.readNickname();
    
    final isAuthenticated = token != null && token.isNotEmpty;
    
    print('🔐 [Auth] 토큰 존재: $isAuthenticated');
    if (isAuthenticated) {
      print('🔐 [Auth] userId: $userId, nickname: $nickname');
    }

    ref.read(authStateProvider.notifier).updateState(AuthState(
      isInitialized: true,
      isAuthenticated: isAuthenticated,
      userId: userId,
      nickname: nickname,
    ));
  }

  /// 익명 로그인 (닉네임 입력 또는 건너뛰기)
  Future<void> signInAnonymous({String? nickname}) async {
    print('🔐 [Auth] 익명 로그인 시도: ${nickname ?? "(닉네임 없음)"}');
    
    final userData = await _repo.signInAnonymous(nickname: nickname);

    ref.read(authStateProvider.notifier).updateState(AuthState(
      isInitialized: true,
      isAuthenticated: true,
      userId: userData['userId']?.toString(),
      nickname: userData['nickname']?.toString(),
    ));

    print('✅ [Auth] 인증 상태 업데이트 완료');
  }

  /// 로그아웃
  Future<void> logout() async {
    await _repo.logout();
    
    ref.read(authStateProvider.notifier).updateState(AuthState(
      isInitialized: true,
      isAuthenticated: false,
      userId: null,
      nickname: null,
    ));

    print('🔐 [Auth] 로그아웃 완료');
  }

  /// 강제 로그아웃 (401 에러 등)
  Future<void> forceLogout() async {
    await logout();
    print('⚠️ [Auth] 강제 로그아웃');
  }
}

