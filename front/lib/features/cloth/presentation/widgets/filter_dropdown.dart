import 'package:flutter/material.dart';

/// 범용 필터 드롭다운 위젯
class FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?>? onChanged;

  const FilterDropdown({
    super.key,
    required this.label,
    this.value,
    required this.placeholder,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // value가 items에 있는지 확인
    final isValueValid = value == null || 
        items.any((item) => item.value == value);
    final safeValue = isValueValid ? value : null;
    
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
          value: safeValue,
          decoration: InputDecoration(
            hintText: placeholder,
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
          items: items,
          onChanged: onChanged,
          isExpanded: true,
        ),
      ],
    );
  }
}



