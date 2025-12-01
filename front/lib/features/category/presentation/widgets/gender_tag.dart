import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/gender.dart';
import '../../../../shared/styles/tokens.dart';

/// 성별 태그 위젯
class GenderTag extends StatefulWidget {
  final List<Gender> genders;
  final Gender? selectedGender;
  final Function(Gender?)? onGenderSelected;

  const GenderTag({
    super.key,
    required this.genders,
    this.selectedGender,
    this.onGenderSelected,
  });

  @override
  State<GenderTag> createState() => _GenderTagState();
}

class _GenderTagState extends State<GenderTag>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isTouching = false; // 터치 상태 추적

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onGenderTap(Gender? gender) {
    if (widget.onGenderSelected != null) {
      HapticFeedback.lightImpact();
      widget.onGenderSelected!(gender);
    }
  }

  void _onGenderTapDown(Gender? gender) {
    _animationController.forward();
    setState(() {
      _isTouching = true;
    });
  }

  void _onGenderTapUp(Gender? gender) {
    _animationController.reverse();
    setState(() {
      _isTouching = false;
    });
  }

  void _onGenderTapCancel(Gender? gender) {
    _animationController.reverse();
    setState(() {
      _isTouching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final containerWidth = 160.0;
    final containerHeight = 45.0;
    final tagWidth = 50.0;
    final tagHeight = 35.0;
    final fontSize = 18.0;
    final borderRadius = 20.0;

    return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _isTouching ? 1.0 : 0.7, // 터치 시 100%, 아닐 때 70%
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: containerWidth,
                height: containerHeight,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: AppColors.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          // 전체 버튼
          GestureDetector(
            onTap: () => _onGenderTap(null),
            onTapDown: (_) => _onGenderTapDown(null),
            onTapUp: (_) => _onGenderTapUp(null),
            onTapCancel: () => _onGenderTapCancel(null),
              child: Container(
                width: tagWidth,
                height: tagHeight,
                decoration: ShapeDecoration(
                  color: widget.selectedGender == null ? AppColors.activeColor : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '전체',
                    style: TextStyle(
                      color: widget.selectedGender == null ? Colors.white : const Color(0xFF292D32),
                      fontSize: fontSize,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      height: 1.71,
                      letterSpacing: 0.40,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 성별 버튼들
          ...widget.genders.map((gender) {
            final isSelected = widget.selectedGender == gender;
            return GestureDetector(
              onTap: () => _onGenderTap(gender),
              onTapDown: (_) => _onGenderTapDown(gender),
              onTapUp: (_) => _onGenderTapUp(gender),
              onTapCancel: () => _onGenderTapCancel(gender),
              child: Container(
                width: tagWidth,
                height: tagHeight,
                decoration: ShapeDecoration(
                  color: isSelected ? AppColors.activeColor : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      gender.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF292D32),
                        fontSize: fontSize,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        height: 1.71,
                        letterSpacing: 0.40,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          ],
        ),
              ),
            ),
          );
        },
      );
  }
}

