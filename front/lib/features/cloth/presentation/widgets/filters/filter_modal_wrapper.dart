import 'package:flutter/material.dart';
import '../filter_tag.dart';

/// 필터 태그 데이터
class FilterTagData {
  final String label;
  final String type; // 'gender', 'category', 'color', 'price'
  
  const FilterTagData({required this.label, required this.type});
}

/// 필터 모달 공통 래퍼
class FilterModalWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final List<FilterTagData> filterTags; // 필터 태그 데이터
  final Function(String type)? onRemoveTag; // 태그 제거 콜백

  const FilterModalWrapper({
    super.key,
    required this.title,
    required this.child,
    required this.onApply,
    required this.onCancel,
    this.filterTags = const [],
    this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 360, // 고정 높이 (400 → 360)
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: child,
            ),
          ),
          // 선택된 필터 태그 표시
          if (filterTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filterTags.map((tagData) {
                  return FilterTag(
                    label: tagData.label,
                    onRemove: () => onRemoveTag?.call(tagData.type),
                  );
                }).toList(),
              ),
            ),
          // 취소/적용 버튼
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(
                        color: Color(0xFF476A62),
                        width: 1,
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: onApply,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF476A62),
                    ),
                    child: const Text('적용'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
