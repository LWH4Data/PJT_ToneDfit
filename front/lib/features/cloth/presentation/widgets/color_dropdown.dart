import 'package:flutter/material.dart';
import '../../data/color_data.dart';
import 'color_circle.dart';
import 'filter_dropdown.dart';

/// 색상 선택 드롭다운 위젯
class ColorDropdown extends StatelessWidget {
  final String label;
  final String? selectedColorName;
  final ValueChanged<String?>? onChanged;

  const ColorDropdown({
    super.key,
    required this.label,
    this.selectedColorName,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorData.getColors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF292D32),
          ),
        ),
        const SizedBox(height: 8),
        ],
        DropdownButtonFormField<String>(
          value: selectedColorName,
          decoration: InputDecoration(
            hintText: '색상 선택',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF476A62)),
            ),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('전체', style: TextStyle(fontSize: 14)),
            ),
            ...colors.map((colorEntity) {
              return DropdownMenuItem<String>(
                value: colorEntity.name,
                child: Row(
                  children: [
                    ColorCircle(
                      color: colorEntity,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      colorEntity.name,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
          isExpanded: true,
        ),
      ],
    );
  }
}

