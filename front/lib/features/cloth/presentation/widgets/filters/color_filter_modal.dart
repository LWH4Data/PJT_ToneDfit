import 'package:flutter/material.dart';
import '../../../data/color_data.dart';
import 'filter_modal_wrapper.dart';

/// 색상 필터 모달
class ColorFilterModal extends StatelessWidget {
  final String? selectedColor;
  final Function(String?) onColorChanged;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final List<FilterTagData> filterTags;
  final Function(String)? onRemoveTag;

  const ColorFilterModal({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
    required this.onApply,
    required this.onCancel,
    this.filterTags = const [],
    this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ColorData.getColors();
    
    return FilterModalWrapper(
      title: '색상',
      onApply: onApply,
      onCancel: onCancel,
      filterTags: filterTags,
      onRemoveTag: onRemoveTag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 옵션 (단독)
          _buildCheckboxTile(
            label: '전체',
            value: null,
            isSelected: selectedColor == null,
            onChanged: () => onColorChanged(null),
          ),
          // 색상 옵션 (2열 그리드)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 4,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            children: colors.map((color) {
              return _buildCheckboxTile(
                label: color.name,
                value: color.name,
                isSelected: selectedColor == color.name,
                onChanged: () => onColorChanged(color.name),
                colorHex: color.hexCode,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCheckboxTile({
    required String label,
    required String? value,
    required bool isSelected,
    required VoidCallback onChanged,
    String? colorHex,
  }) {
    return InkWell(
      onTap: onChanged,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              onChanged: (_) => onChanged(),
              activeColor: const Color(0xFF476A62),
            ),
            const SizedBox(width: 8),
            // 색상 원 표시
            if (colorHex != null) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(int.parse(colorHex.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF476A62) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
