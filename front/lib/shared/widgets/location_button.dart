import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';
import 'location_permission_dialog.dart';

/// 위치 가져오기 버튼 위젯
/// 
/// 한 번의 탭으로 위치 권한을 요청하고 위치를 가져올 수 있는 간편한 버튼입니다.
class LocationButton extends StatefulWidget {
  /// 위치를 가져온 후 호출되는 콜백
  final Function(Position position)? onLocationReceived;

  /// 위치 가져오기에 실패했을 때 호출되는 콜백
  final Function()? onLocationFailed;

  /// 버튼 텍스트
  final String text;

  /// 버튼 아이콘
  final IconData icon;

  /// 버튼 스타일
  final ButtonStyle? style;

  /// 다이얼로그 사용 여부
  final bool useDialog;

  const LocationButton({
    super.key,
    this.onLocationReceived,
    this.onLocationFailed,
    this.text = '현재 위치 가져오기',
    this.icon = Icons.my_location,
    this.style,
    this.useDialog = true,
  });

  @override
  State<LocationButton> createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> {
  final LocationService _locationService = LocationService();
  late final LocationPermissionDialog _permissionDialog;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _permissionDialog = LocationPermissionDialog(_locationService);
  }

  Future<void> _handleLocationRequest() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      Position? position;

      if (widget.useDialog) {
        position = await _permissionDialog.requestLocationWithDialog(context);
      } else {
        position = await _locationService.handleLocationPermission();
      }

      if (position != null) {
        widget.onLocationReceived?.call(position);
      } else {
        widget.onLocationFailed?.call();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handleLocationRequest,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(widget.icon),
      label: Text(widget.text),
      style: widget.style,
    );
  }
}

/// 간단한 위치 정보 표시 위젯
class LocationDisplay extends StatelessWidget {
  final Position? position;
  final String emptyMessage;

  const LocationDisplay({
    super.key,
    required this.position,
    this.emptyMessage = '위치 정보가 없습니다.',
  });

  @override
  Widget build(BuildContext context) {
    if (position == null) {
      return Text(
        emptyMessage,
        style: const TextStyle(color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow('위도', position!.latitude.toStringAsFixed(6)),
        const SizedBox(height: 4),
        _buildRow('경도', position!.longitude.toStringAsFixed(6)),
        const SizedBox(height: 4),
        _buildRow('정확도', '±${position!.accuracy.toStringAsFixed(1)}m'),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 간단한 사용 예제:
/// 
/// ```dart
/// Position? _currentPosition;
/// 
/// LocationButton(
///   onLocationReceived: (position) {
///     setState(() {
///       _currentPosition = position;
///     });
///   },
///   onLocationFailed: () {
///     print('위치를 가져올 수 없습니다.');
///   },
/// )
/// 
/// LocationDisplay(position: _currentPosition)
/// ```



