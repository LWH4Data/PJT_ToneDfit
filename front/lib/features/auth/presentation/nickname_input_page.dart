import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/router/app_router.dart';
import 'providers/auth_provider.dart';

/// 닉네임 입력 페이지
class NicknameInputPage extends ConsumerStatefulWidget {
  const NicknameInputPage({super.key});

  @override
  ConsumerState<NicknameInputPage> createState() => _NicknameInputPageState();
}

class _NicknameInputPageState extends ConsumerState<NicknameInputPage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_validateNickname);
  }

  void _validateNickname() {
    final nickname = _nicknameController.text.trim();
    setState(() {
      _isValid = nickname.isNotEmpty && nickname.length >= 2 && nickname.length <= 10;
    });
  }

  /// 닉네임으로 시작하기
  Future<void> _submitWithNickname() async {
    if (!_isValid) return;
    
    final nickname = _nicknameController.text.trim();
    await _signIn(nickname: nickname);
  }

  /// 건너뛰고 시작하기
  Future<void> _submitWithoutNickname() async {
    await _signIn(nickname: null);
  }

  /// 익명 로그인 실행
  Future<void> _signIn({String? nickname}) async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authControllerProvider).signInAnonymous(nickname: nickname);
      
      if (mounted) {
        // 홈 화면으로 이동
        Navigator.pushReplacementNamed(context, AppRouter.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 여백
              const Spacer(flex: 2),
              
              // 환영 텍스트
              const Text(
                '환영합니다!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF292D32),
                  fontSize: 32,
                  fontFamily: 'S-Core Dream',
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '톤디핏과 함께할 닉네임을 입력해주세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 16,
                  fontFamily: 'S-Core Dream',
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // 닉네임 입력창
              TextField(
                controller: _nicknameController,
                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitWithNickname(),
                maxLength: 10,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF292D32),
                ),
                decoration: InputDecoration(
                  hintText: '닉네임 (2-10자)',
                  hintStyle: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 18,
                  ),
                  counterText: '', // 글자 수 카운터 숨김
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFFB4A6E), // 브랜드 컬러
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF5350),
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFEF5350),
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 닉네임으로 시작하기 버튼
              FilledButton(
                onPressed: (_isValid && !_isLoading) ? _submitWithNickname : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFB4A6E), // 브랜드 컬러
                  disabledBackgroundColor: const Color(0xFFE0E0E0),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        '닉네임으로 시작하기',
                        style: TextStyle(
                          color: _isValid ? Colors.white : const Color(0xFFBDBDBD),
                          fontSize: 18,
                          fontFamily: 'S-Core Dream',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const SizedBox(height: 12),
              
              // 건너뛰기 버튼
              TextButton(
                onPressed: !_isLoading ? _submitWithoutNickname : null,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text(
                  '건너뛰고 시작하기',
                  style: TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 16,
                    fontFamily: 'S-Core Dream',
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 안내 텍스트
              if (_nicknameController.text.isNotEmpty && !_isValid)
                const Text(
                  '닉네임은 2-10자 사이로 입력해주세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFEF5350),
                    fontSize: 12,
                    fontFamily: 'S-Core Dream',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              
              // 하단 여백
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

