import 'package:flutter/material.dart';
import '../../../data/category_data.dart';
import 'filter_modal_wrapper.dart';

/// 성별 필터 모달
class GenderFilterModal extends StatelessWidget {
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final List<FilterTagData> filterTags;
  final Function(String)? onRemoveTag;

  const GenderFilterModal({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onApply,
    required this.onCancel,
    this.filterTags = const [],
    this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    final genders = CategoryData.getGenders();
    
    return FilterModalWrapper(
      title: '성별',
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
            isSelected: selectedGender == null,
            onChanged: () => onGenderChanged(null),
          ),
          // 성별 옵션 (2열 그리드)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 4,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            children: genders.map((gender) {
              return _buildCheckboxTile(
                label: gender.name,
                value: gender.name,
                isSelected: selectedGender == gender.name,
                onChanged: () => onGenderChanged(gender.name),
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

