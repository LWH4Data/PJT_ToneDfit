/// 인증 상태
class AuthState {
  final bool isInitialized; // 스토리지 로드 완료 여부
  final bool isAuthenticated; // 토큰 존재 여부
  final String? userId; // 사용자 UUID
  final String? nickname; // 사용자 닉네임

  const AuthState({
    required this.isInitialized,
    required this.isAuthenticated,
    this.userId,
    this.nickname,
  });

  AuthState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    String? userId,
    String? nickname,
  }) {
    return AuthState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
    );
  }

  static const initial = AuthState(
    isInitialized: false,
    isAuthenticated: false,
  );
}

