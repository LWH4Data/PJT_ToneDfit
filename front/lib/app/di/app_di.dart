import 'package:get_it/get_it.dart';

// Dependency Injection 설정
final GetIt getIt = GetIt.instance;

class AppDI {
  static Future<void> init() async {
    // TODO: 실제 서비스들을 추가할 때 여기에 등록
    // 현재는 기본 설정만
  }
  
  static void reset() {
    getIt.reset();
  }
}
