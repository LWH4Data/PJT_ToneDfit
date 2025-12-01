import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../styles/tokens.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(4, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
    });
    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.05, // 1.1에서 1.05로 변경 (덜 튕기게)
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onNavItemTap(int index) {
    // 미세한 진동 피드백
    HapticFeedback.lightImpact();
    
    // 상태 변경 (색깔 변경)
    widget.onTap(index);
  }

  void _onNavItemTapDown(int index) {
    // 미세한 진동 피드백
    HapticFeedback.lightImpact();
    // 손으로 누르면 작아지게
    _animationControllers[index].forward();
  }

  void _onNavItemTapUp(int index) {
    // 손을 떼면 원래 크기로
    _animationControllers[index].reverse();
  }

  void _onNavItemTapCancel(int index) {
    // 터치가 취소되면 원래 크기로
    _animationControllers[index].reverse();
  }

  @override
  Widget build(BuildContext context) {
    // 고정 크기 사용
    final navHeight = 85.0;
    final navWidth = double.infinity;

    return Container(
      width: navWidth,
      height: navHeight,
      margin: EdgeInsets.only(
        bottom: 0, // 하단 마진 제거하여 화면 하단과 딱 맞게
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: '홈',
            index: 0,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.wb_sunny_outlined,
            activeIcon: Icons.wb_sunny,
            label: '날씨',
            index: 1,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view,
            label: '카테고리',
            index: 2,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: '프로필',
            index: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = widget.currentIndex == index;
    // 고정 크기 사용
    final iconSize = 22.5;
    final fontSize = 13.5;
    final spacing = 6.0;
    final navHeight = 85.0;

    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _onNavItemTap(index),
            onTapDown: (_) => _onNavItemTapDown(index),
            onTapUp: (_) => _onNavItemTapUp(index),
            onTapCancel: () => _onNavItemTapCancel(index),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              height: navHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 균등 분배
                children: [
                  // 아이콘
                  Icon(
                    isActive ? activeIcon : icon,
                    size: iconSize,
                    color: isActive 
                      ? AppColors.activeColor 
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  // 텍스트
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive 
                        ? AppColors.activeColor 
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                      fontSize: fontSize,
                      fontFamily: 'NanumSquare Neo',
                      fontWeight: AppTypography.fontWeightBold,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}