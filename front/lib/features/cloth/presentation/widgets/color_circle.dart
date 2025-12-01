import 'package:flutter/material.dart';
import '../../domain/entities/color_entity.dart';

/// 의상 색상을 표시하는 원형 위젯
class ColorCircle extends StatelessWidget {
  final ColorEntity color;
  final double size;
  final VoidCallback? onTap;
  final bool isSelected;

  const ColorCircle({
    super.key,
    required this.color,
    this.size = 18.0,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // "기타"는 hexCode가 없으므로 특별 처리
    final isOther = color.hexCode == null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOther 
              ? Colors.white 
              : _parseColor(color.hexCode!),
          border: Border.all(
            color: const Color(0xFF303E51),
            width: 0.5,
          ),
        ),
        // "기타"인 경우 텍스트 표시
        child: isOther
            ? Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: size * 0.6,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF303E51),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  /// Hex 색상 코드를 Color로 변환
  Color _parseColor(String hexCode) {
    final hex = hexCode.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}



