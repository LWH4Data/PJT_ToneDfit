import 'package:shared_preferences/shared_preferences.dart';

/// 위치 권한 관련 SharedPreferences 관리
class LocationPreferenceService {
  static const String _keyPermissionGranted = 'location_permission_granted';

  /// 위치 권한 허용 여부 확인 (기본값: false)
  static Future<bool> isLocationPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPermissionGranted) ?? false;
  }

  /// 위치 권한 허용 여부 설정
  static Future<void> setLocationPermissionGranted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPermissionGranted, value);
  }
}

