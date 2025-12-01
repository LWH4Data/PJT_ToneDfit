import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../shared/index.dart';
import '../../../shared/utils/navigation_helper.dart';
import '../../../app/router/app_router.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/location_preference_service.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../character_outfit/presentation/widgets/index.dart';

/// 프로필 페이지
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> 
    with BottomNavScrollMixin, WidgetsBindingObserver {
  int _currentIndex = 3; // 프로필 탭이 활성화
  final ScrollController _scrollController = ScrollController();
  final LocationService _locationService = LocationService();
  
  LocationPermission? _currentPermission;
  bool _isLocationServiceEnabled = false;
  Position? _currentPosition; // 현재 위치 정보
  bool _isLoadingLocation = false;
  bool _isWaitingForSettings = false; // 설정 화면에서 돌아오기를 기다리는 중

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 라이프사이클 옵저버 등록
    _scrollController.addListener(_onScroll);
    _loadLocationStatus();
    _loadCurrentLocation();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 옵저버 제거
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      _isWaitingForSettings = false;
      _loadLocationStatus();
      _loadCurrentLocation();
    }
  }
  
  
  /// 현재 위치 권한 상태 로드 및 동기화
  Future<void> _loadLocationStatus() async {
    try {
      final permission = await _locationService.checkPermission();
      final serviceEnabled = await _locationService.isLocationServiceEnabled();
      
      // SharedPreferences에 동기화
      final isGranted = (permission == LocationPermission.whileInUse || 
                        permission == LocationPermission.always);
      await LocationPreferenceService.setLocationPermissionGranted(isGranted);
      
      if (mounted) {
        setState(() {
          _currentPermission = permission;
          _isLocationServiceEnabled = serviceEnabled;
        });
      }
    } catch (e) {
      debugPrint('위치 권한 상태 로드 오류: $e');
    }
  }
  
  /// 현재 위치 정보 로드
  Future<void> _loadCurrentLocation() async {
    final isGranted = await LocationPreferenceService.isLocationPermissionGranted();
    if (!isGranted) return;
    
    setState(() => _isLoadingLocation = true);
    
    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint('위치 정보 로드 오류: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }
  
  /// 위치 정보 새로고침
  Future<void> _refreshLocation() async {
    if (!_isLocationPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위치 권한이 필요합니다'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    await _loadCurrentLocation();
    
    if (mounted && _currentPosition != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 위치 정보가 업데이트되었습니다'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onScroll() {
    // 하단 네비게이션 애니메이션 처리 (Mixin 사용)
    handleBottomNavScroll(_scrollController.position.pixels);
  }

  void _onNavTap(int index) {
    // 같은 페이지면 무시
    if (index == _currentIndex) return;
    NavigationHelper.handleBottomNavTap(context, index);
  }
  
  /// 위치 권한이 허용되어 있는지 확인
  bool get _isLocationPermissionGranted {
    return _currentPermission == LocationPermission.whileInUse ||
           _currentPermission == LocationPermission.always;
  }
  
  /// 위치 권한 토글 변경
  Future<void> _onLocationToggleChanged(bool value) async {
    if (value) {
      await _requestLocationPermission();
    } else {
      await _showDisableLocationGuide();
    }
  }
  
  /// 위치 권한 요청 (토글 ON)
  Future<void> _requestLocationPermission() async {
    try {
      // 1. 위치 서비스 확인
      if (!await _checkLocationService()) return;

      // 2. 권한 요청
      var permission = await _locationService.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        permission = await _locationService.requestPermission();
      }

      // 3. 결과 처리
      await _handlePermissionResult(permission);
    } catch (e) {
      debugPrint('위치 권한 요청 오류: $e');
      await _loadLocationStatus();
    }
  }
  
  /// 위치 서비스 활성화 확인
  Future<bool> _checkLocationService() async {
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled && mounted) {
      final shouldOpen = await _showSettingsDialog(
        title: '위치 서비스 꺼짐',
        message: '위치 서비스가 비활성화되어 있습니다.\n기기 설정에서 위치 서비스를 켜주세요.',
      );
      
      if (shouldOpen) {
        await _openSettings(() => _locationService.openLocationSettings());
      }
      await _loadLocationStatus();
      return false;
    }
    return true;
  }
  
  /// 권한 결과 처리
  Future<void> _handlePermissionResult(LocationPermission permission) async {
    await _loadLocationStatus();
      
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // 권한 허용됨
        await LocationPreferenceService.setLocationPermissionGranted(true);
        await _loadCurrentLocation();
      _showSnackBar('✅ 위치 권한이 허용되었습니다');
    } else {
      // 권한 거부됨
      await LocationPreferenceService.setLocationPermissionGranted(false);
      if (mounted) {
        setState(() => _currentPosition = null);
        
        if (permission == LocationPermission.deniedForever) {
          // 설정 안내
          final shouldOpen = await _showSettingsDialog(
            title: '설정에서 권한 허용 필요',
            message: '위치 권한을 허용하려면\n앱 설정으로 이동해야 합니다.',
          );
          
          if (shouldOpen) {
            await _openSettings(() => _locationService.openAppSettings());
        }
      } else {
          _showSnackBar('❌ 위치 권한이 거부되었습니다.');
        }
      }
    }
  }
  
  /// 설정 다이얼로그 표시
  Future<bool> _showSettingsDialog({
    required String title,
    required String message,
  }) async {
    if (!mounted) return false;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // 배경색 하얀색
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF303E51), // 취소 텍스트 색상
            ),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCF6A7),
              foregroundColor: const Color(0xFF292D32),
            ),
            child: const Text('설정 열기'),
          ),
        ],
      ),
    );
    
    return result == true;
  }
  
  /// 설정 열기
  Future<void> _openSettings(Future<bool> Function() openSettings) async {
    setState(() => _isWaitingForSettings = true);
    await openSettings();
  }
  
  /// 스낵바 표시
  void _showSnackBar(String message) {
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
  
  /// 위치 권한 비활성화 안내 (토글 OFF)
  Future<void> _showDisableLocationGuide() async {
    final shouldOpen = await _showSettingsDialog(
      title: '위치 권한 끄기',
      message: '위치 권한을 끄려면 시스템 설정으로 이동해야 합니다.\n\n'
          '설정 > 권한 > 위치에서\n'
          '권한을 거부할 수 있습니다.',
    );
    
    if (shouldOpen) {
      await _openSettings(() => _locationService.openAppSettings());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 메인 컨텐츠
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    
                    // 프로필 헤더
                    const Text(
                      '프로필',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // 설정 섹션
                    _buildSectionTitle('설정'),
                    const SizedBox(height: 12),
                    
                    // 위치 권한 토글
                    _buildLocationToggleCard(),
                    
                    // 위치 정보 표시 (권한 허용 시)
                    if (_isLocationPermissionGranted) ...[
                      const SizedBox(height: 12),
                      _buildLocationInfoCard(),
                    ],
                    
                    const SizedBox(height: 30),
                    
                    // 계정 섹션
                    _buildSectionTitle('계정'),
                    const SizedBox(height: 12),
                    
                    // 닉네임 표시
                    _buildAccountInfoCard(),
                    
                    const SizedBox(height: 12),
                    
                    // 로그아웃 버튼
                    _buildLogoutCard(),
                    
                    const SizedBox(height: 30),
                    
                    // 🧪 테스트: 캐릭터 옷 입히기
                    _buildSectionTitle('🧪 테스트 기능'),
                    const SizedBox(height: 12),
                    _buildCharacterOutfitCard(),
                    
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Navigation - 스크롤 위치에 따라 애니메이션
          Positioned(
            left: 0,
            right: 0,
            bottom: getNavBottom(navOpacity),
            child: Opacity(
              opacity: navOpacity,
              child: IgnorePointer(
                ignoring: navOpacity < 0.5,
                child: BottomNavigation(
                  currentIndex: _currentIndex,
                  onTap: _onNavTap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF666666),
        ),
      ),
    );
  }
  
  /// 위치 권한 토글 카드
  Widget _buildLocationToggleCard() {
    final isEnabled = _isLocationPermissionGranted;
    
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on,
                size: 24,
                color: Color(0xFF292D32),
              ),
            ),
            const SizedBox(width: 16),
            
            // 제목 및 상태
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '위치 권한',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF292D32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEnabled ? '✅ 허용됨' : '❌ 거부됨',
                    style: TextStyle(
                      fontSize: 14,
                      color: isEnabled ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // 토글 스위치
            Switch(
              value: isEnabled,
              onChanged: _onLocationToggleChanged,
              activeColor: const Color(0xFFFCF6A7),
              activeTrackColor: const Color(0xFFFCF6A7).withOpacity(0.5),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
  
  /// 위치 정보 카드
  Widget _buildLocationInfoCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.my_location,
                        size: 24,
                        color: Color(0xFF292D32),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '현재 위치',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF292D32),
                      ),
                    ),
                  ],
                ),
                // 새로고침 버튼
                IconButton(
                  onPressed: _isLoadingLocation ? null : _refreshLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  iconSize: 20,
                  color: const Color(0xFF666666),
                  tooltip: '새로고침',
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 위치 정보
            if (_currentPosition != null) ...[
              _buildLocationRow(
                '위도',
                _currentPosition!.latitude.toStringAsFixed(6),
                Icons.south_outlined,
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                '경도',
                _currentPosition!.longitude.toStringAsFixed(6),
                Icons.east_outlined,
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                '정확도',
                '±${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                Icons.radar_outlined,
              ),
              const SizedBox(height: 12),
              _buildLocationRow(
                '마지막 업데이트',
                _formatTimestamp(_currentPosition!.timestamp),
                Icons.schedule,
              ),
            ] else if (_isLoadingLocation) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '위치 정보를 가져올 수 없습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _refreshLocation,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// 위치 정보 행
  Widget _buildLocationRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF666666),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF292D32),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// 타임스탬프 포맷팅
  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '-';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inSeconds < 60) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    }
  }
  
  /// 계정 정보 카드
  Widget _buildAccountInfoCard() {
    final authState = ref.watch(authStateProvider);
    final nickname = authState.nickname ?? '익명';
    final userId = authState.userId ?? '-';
    
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person,
                size: 24,
                color: Color(0xFF292D32),
              ),
            ),
            const SizedBox(width: 16),
            
            // 닉네임
            Expanded(
              child: Text(
                nickname,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF292D32),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 로그아웃 카드
  Widget _buildLogoutCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: _logout,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout,
                  size: 24,
                  color: Color(0xFFEF5350),
                ),
              ),
              const SizedBox(width: 16),
              
              // 텍스트
              const Expanded(
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF5350),
                  ),
                ),
              ),
              
              // 화살표
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 로그아웃 처리
  Future<void> _logout() async {
    // 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white, // 배경색 하얀색
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF303E51), // 취소 텍스트 색상
            ),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      try {
        await ref.read(authControllerProvider).logout();
        
        // 닉네임 입력 페이지로 이동
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.nickname,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그아웃 실패: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  /// 설정 카드 위젯
  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: const Color(0xFF292D32),
                ),
              ),
              const SizedBox(width: 16),
              
              // 제목 및 부제목
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF292D32),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor ?? const Color(0xFF999999),
                          fontWeight: statusColor != null 
                              ? FontWeight.w600 
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 화살표 (탭 가능한 경우)
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCCCCCC),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 캐릭터 옷 입히기 카드 (테스트용)
  Widget _buildCharacterOutfitCard() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: _openCharacterOutfitModal,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF6A7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.checkroom,
                  size: 24,
                  color: Color(0xFF292D32),
                ),
              ),
              const SizedBox(width: 16),
              
              // 제목
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '캐릭터 옷 입히기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF292D32),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'AI로 캐릭터에 옷을 입혀보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 화살표
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFCCCCCC),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 캐릭터 옷 입히기 모달 열기
  void _openCharacterOutfitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      '🎨 캐릭터 옷 입히기',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // 컨텐츠
            const Expanded(
              child: CharacterOutfitFullWidget(),
            ),
          ],
        ),
      ),
    );
  }
}




