import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

/// 위치 권한 및 위치 정보를 관리하는 서비스 클래스
class LocationService {
  final Logger _logger = Logger();

  /// 1단계: 위치 권한 상태 확인
  Future<LocationPermission> checkPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      _logger.i('현재 위치 권한 상태: $permission');
      return permission;
    } catch (e) {
      _logger.e('위치 권한 확인 오류: $e');
      rethrow;
    }
  }

  /// 위치 서비스가 활성화되어 있는지 확인
  Future<bool> isLocationServiceEnabled() async {
    try {
      final isEnabled = await Geolocator.isLocationServiceEnabled();
      _logger.i('위치 서비스 활성화 상태: $isEnabled');
      return isEnabled;
    } catch (e) {
      _logger.e('위치 서비스 활성화 확인 오류: $e');
      rethrow;
    }
  }

  /// 3단계: 위치 권한 요청
  Future<LocationPermission> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      _logger.i('위치 권한 요청 결과: $permission');
      return permission;
    } catch (e) {
      _logger.e('위치 권한 요청 오류: $e');
      rethrow;
    }
  }

  /// 4단계: 현재 위치 가져오기
  Future<Position> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, // 높은 정확도
          distanceFilter: 10, // 10미터 이상 이동 시 업데이트
        ),
      );
      _logger.i('현재 위치: 위도=${position.latitude}, 경도=${position.longitude}');
      return position;
    } catch (e) {
      _logger.e('위치 가져오기 오류: $e');
      rethrow;
    }
  }

  /// 5단계: 설정으로 이동
  Future<bool> openAppSettings() async {
    try {
      final opened = await Geolocator.openAppSettings();
      _logger.i('앱 설정 열기 결과: $opened');
      return opened;
    } catch (e) {
      _logger.e('앱 설정 열기 오류: $e');
      rethrow;
    }
  }

  /// 위치 서비스 열기 (위치 서비스가 비활성화된 경우)
  Future<bool> openLocationSettings() async {
    try {
      final opened = await Geolocator.openLocationSettings();
      _logger.i('위치 서비스 설정 열기 결과: $opened');
      return opened;
    } catch (e) {
      _logger.e('위치 서비스 설정 열기 오류: $e');
      rethrow;
    }
  }

  /// 전체 위치 권한 요청 플로우
  /// 
  /// 반환값:
  /// - Position: 위치 정보를 성공적으로 가져온 경우
  /// - null: 권한이 거부되거나 위치 서비스가 비활성화된 경우
  Future<Position?> handleLocationPermission() async {
    try {
      // 1. 위치 서비스 활성화 확인
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _logger.w('위치 서비스가 비활성화되어 있습니다.');
        return null;
      }

      // 2. 현재 권한 상태 확인
      LocationPermission permission = await checkPermission();

      // 3. 권한이 거부된 경우 요청
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        
        if (permission == LocationPermission.denied) {
          _logger.w('위치 권한이 거부되었습니다.');
          return null;
        }
      }

      // 4. 권한이 영구적으로 거부된 경우
      if (permission == LocationPermission.deniedForever) {
        _logger.w('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
        return null;
      }

      // 5. 권한이 허용된 경우 위치 정보 가져오기
      final position = await getCurrentPosition();
      return position;
    } catch (e) {
      _logger.e('위치 권한 처리 오류: $e');
      return null;
    }
  }

  /// 위치 변경사항을 실시간으로 스트리밍
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// 두 지점 사이의 거리 계산 (미터 단위)
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// 현재 위치와 특정 지점 사이의 거리 계산
  Future<double?> getDistanceFromCurrentLocation(
    double targetLatitude,
    double targetLongitude,
  ) async {
    try {
      final position = await getCurrentPosition();
      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        targetLatitude,
        targetLongitude,
      );
      return distance;
    } catch (e) {
      _logger.e('거리 계산 오류: $e');
      return null;
    }
  }
}



