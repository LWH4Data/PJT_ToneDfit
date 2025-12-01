import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/location_preference_service.dart';
import '../../../shared/widgets/location_permission_dialog.dart';

/// 위치 권한 및 위치 정보 사용 예제 페이지
class LocationExamplePage extends StatefulWidget {
  const LocationExamplePage({super.key});

  @override
  State<LocationExamplePage> createState() => _LocationExamplePageState();
}

class _LocationExamplePageState extends State<LocationExamplePage> 
    with WidgetsBindingObserver {
  final LocationService _locationService = LocationService();
  late final LocationPermissionDialog _permissionDialog;

  Position? _currentPosition;
  LocationPermission? _permissionStatus;
  bool _isServiceEnabled = false;
  bool _isLoading = false;
  bool _isWaitingForSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permissionDialog = LocationPermissionDialog(_locationService);
    _checkInitialStatus();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed && _isWaitingForSettings) {
      _isWaitingForSettings = false;
      _checkInitialStatus();
    }
  }

  /// 초기 상태 확인
  Future<void> _checkInitialStatus() async {
    setState(() => _isLoading = true);

    try {
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      final permission = await _locationService.checkPermission();

      // 시스템 권한 상태를 저장소에 동기화
      final isGranted = (permission == LocationPermission.whileInUse || 
                        permission == LocationPermission.always);
      await LocationPreferenceService.setLocationPermissionGranted(isGranted);
      debugPrint('💾 위치 권한 상태 저장소에 저장: $isGranted');

      setState(() {
        _isServiceEnabled = serviceEnabled;
        _permissionStatus = permission;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 위치 권한 요청 (다이얼로그 포함)
  Future<void> _requestLocationWithDialog() async {
    setState(() => _isLoading = true);

    try {
      final position = await _permissionDialog.requestLocationWithDialog(context);

      setState(() {
        _currentPosition = position;
      });

      await _checkInitialStatus();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 위치 권한 요청 (다이얼로그 없이)
  Future<void> _requestLocationDirect() async {
    setState(() => _isLoading = true);

    try {
      final position = await _locationService.handleLocationPermission();

      setState(() {
        _currentPosition = position;
      });

      if (mounted) {
        if (position != null) {
          _showMessage('위치를 가져왔습니다!');
        } else {
          _showMessage('위치를 가져오는데 실패했습니다.');
        }
      }

      await _checkInitialStatus();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// 현재 위치 새로고침
  Future<void> _refreshLocation() async {
    if (_permissionStatus == LocationPermission.whileInUse ||
        _permissionStatus == LocationPermission.always) {
      setState(() => _isLoading = true);

      try {
        final position = await _locationService.getCurrentPosition();

        setState(() {
          _currentPosition = position;
        });

        _showMessage('위치가 업데이트되었습니다!');
      } catch (e) {
        _showMessage('위치 업데이트에 실패했습니다.');
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      _showMessage('위치 권한이 필요합니다.');
    }
  }

  /// 앱 설정 열기
  Future<void> _openAppSettings() async {
    setState(() => _isWaitingForSettings = true);
    await _locationService.openAppSettings();
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 권한 예제'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  /// 상태 카드
  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📍 위치 서비스 상태',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              '위치 서비스',
              _isServiceEnabled ? '활성화됨' : '비활성화됨',
              _isServiceEnabled ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              '권한 상태',
              _getPermissionStatusText(),
              _getPermissionStatusColor(),
            ),
          ],
        ),
      ),
    );
  }

  /// 위치 정보 카드
  Widget _buildLocationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📌 현재 위치',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentPosition != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshLocation,
                    tooltip: '새로고침',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentPosition != null) ...[
              _buildLocationRow(
                '위도',
                _currentPosition!.latitude.toStringAsFixed(6),
              ),
              const SizedBox(height: 8),
              _buildLocationRow(
                '경도',
                _currentPosition!.longitude.toStringAsFixed(6),
              ),
              const SizedBox(height: 8),
              _buildLocationRow(
                '정확도',
                '${_currentPosition!.accuracy.toStringAsFixed(2)}m',
              ),
              const SizedBox(height: 8),
              _buildLocationRow(
                '고도',
                '${_currentPosition!.altitude.toStringAsFixed(2)}m',
              ),
            ] else
              const Text(
                '위치 정보가 없습니다.\n아래 버튼을 눌러 위치를 가져오세요.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _requestLocationWithDialog,
          icon: const Icon(Icons.location_on),
          label: const Text('위치 가져오기 (다이얼로그)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _requestLocationDirect,
          icon: const Icon(Icons.gps_fixed),
          label: const Text('위치 가져오기 (직접)'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _openAppSettings,
          icon: const Icon(Icons.settings),
          label: const Text('앱 설정 열기'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  /// 상태 행 위젯
  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// 위치 정보 행 위젯
  Widget _buildLocationRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 권한 상태 텍스트 가져오기
  String _getPermissionStatusText() {
    switch (_permissionStatus) {
      case LocationPermission.denied:
        return '거부됨';
      case LocationPermission.deniedForever:
        return '영구 거부됨';
      case LocationPermission.whileInUse:
        return '사용 중 허용';
      case LocationPermission.always:
        return '항상 허용';
      default:
        return '확인 중...';
    }
  }

  /// 권한 상태 색상 가져오기
  Color _getPermissionStatusColor() {
    switch (_permissionStatus) {
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
        return Colors.red;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}


