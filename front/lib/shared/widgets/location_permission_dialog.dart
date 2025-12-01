import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';

/// 위치 권한 요청 다이얼로그
class LocationPermissionDialog {
  final LocationService _locationService;

  LocationPermissionDialog(this._locationService);

  /// 2단계: 권한 요청 안내 다이얼로그 표시
  Future<bool?> showPermissionRequestDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // 다이얼로그 외부 클릭으로 닫기 방지
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              SizedBox(width: 8),
              Text('위치 권한 필요'),
            ],
          ),
          content: const Text(
            '이 앱은 위치 정보를 사용하여 더 나은 서비스를 제공합니다.\n\n'
            '위치 권한을 허용하시겠습니까?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '거부',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('허용'),
            ),
          ],
        );
      },
    );
  }

  /// 5단계: 권한 거부 시 설정으로 이동 안내 다이얼로그
  Future<bool?> showSettingsDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.settings, color: Colors.orange),
              SizedBox(width: 8),
              Text('권한 설정 필요'),
            ],
          ),
          content: const Text(
            '위치 권한이 거부되었습니다.\n\n'
            '앱 설정에서 위치 권한을 허용해주세요.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('설정으로 이동'),
            ),
          ],
        );
      },
    );
  }

  /// 위치 서비스 비활성화 안내 다이얼로그
  Future<bool?> showLocationServiceDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8),
              Text('위치 서비스 비활성화'),
            ],
          ),
          content: const Text(
            '위치 서비스가 비활성화되어 있습니다.\n\n'
            '기기 설정에서 위치 서비스를 활성화해주세요.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('설정으로 이동'),
            ),
          ],
        );
      },
    );
  }

  /// 전체 위치 권한 요청 플로우 (다이얼로그 포함)
  /// 
  /// 사용자와의 상호작용을 포함한 완전한 위치 권한 요청 플로우
  /// 
  /// 반환값:
  /// - Position: 위치 정보를 성공적으로 가져온 경우
  /// - null: 권한이 거부되거나 사용자가 취소한 경우
  Future<Position?> requestLocationWithDialog(BuildContext context) async {
    // 1. 위치 서비스 활성화 확인
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!context.mounted) return null;
      
      final shouldOpenSettings = await showLocationServiceDialog(context);
      if (shouldOpenSettings == true) {
        await _locationService.openLocationSettings();
      }
      return null;
    }

    // 2. 현재 권한 상태 확인
    LocationPermission permission = await _locationService.checkPermission();

    // 3. 권한이 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      if (!context.mounted) return null;
      
      final shouldOpenSettings = await showSettingsDialog(context);
      if (shouldOpenSettings == true) {
        await _locationService.openAppSettings();
      }
      return null;
    }

    // 4. 권한이 거부된 경우 안내 다이얼로그 표시
    if (permission == LocationPermission.denied) {
      if (!context.mounted) return null;
      
      final shouldRequest = await showPermissionRequestDialog(context);
      
      // 사용자가 "허용"을 선택한 경우 권한 요청
      if (shouldRequest == true) {
        permission = await _locationService.requestPermission();
        
        if (permission == LocationPermission.denied) {
          if (!context.mounted) return null;
          
          _showSnackBar(context, '위치 권한이 거부되었습니다.');
          return null;
        }
      } else {
        return null;
      }
    }

    // 5. 권한이 허용된 경우 위치 정보 가져오기
    try {
      final position = await _locationService.getCurrentPosition();
      
      if (context.mounted) {
        _showSnackBar(
          context,
          '현재 위치: 위도 ${position.latitude.toStringAsFixed(4)}, '
          '경도 ${position.longitude.toStringAsFixed(4)}',
        );
      }
      
      return position;
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, '위치를 가져오는데 실패했습니다.');
      }
      return null;
    }
  }

  /// 스낵바 표시 헬퍼 메서드
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}


