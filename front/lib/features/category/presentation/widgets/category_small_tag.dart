import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/category_small.dart';
import '../../../../shared/styles/tokens.dart';

class CategorySmallTag extends StatelessWidget {
  final CategorySmall? category;
  final String? label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategorySmallTag({
    super.key,
    this.category,
    this.label,
    this.isSelected = false,
    this.onTap,
  }) : assert(category != null || label != null, 'Either category or label must be provided');

  String get _displayLabel => category?.name ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    // 고정 크기 사용
    final horizontalPadding = 18.0;
    final verticalPadding = 2.0;
    final fontSize = 12.0;
    final borderRadius = 20.0;
    final tagHeight = 24.0;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          // 미세한 진동 피드백
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        height: tagHeight,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.activeColor : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected ? AppColors.activeColor : AppColors.borderColor,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _displayLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: fontSize,
                fontFamily: 'S-Core Dream',
                fontWeight: FontWeight.w500,
                height: 1.66,
                letterSpacing: 0.40,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

