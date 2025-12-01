import 'package:flutter/material.dart';
import '../../../data/category_data.dart';
import '../../../../category/domain/entities/category_large.dart';
import '../../../../category/domain/entities/category_small.dart';
import 'filter_modal_wrapper.dart';

/// 카테고리 필터 모달 (좌우 분할)
class CategoryFilterModal extends StatefulWidget {
  final String? selectedGender;
  final String? selectedLargeName; // ID → 이름
  final String? selectedSmallName; // ID → 이름
  final Function(String?) onLargeChanged;
  final Function(String?) onSmallChanged;
  final VoidCallback onApply;
  final VoidCallback onCancel;
  final List<FilterTagData> filterTags;
  final Function(String)? onRemoveTag;

  const CategoryFilterModal({
    super.key,
    required this.selectedGender,
    required this.selectedLargeName,
    required this.selectedSmallName,
    required this.onLargeChanged,
    required this.onSmallChanged,
    required this.onApply,
    required this.onCancel,
    this.filterTags = const [],
    this.onRemoveTag,
  });

  @override
  State<CategoryFilterModal> createState() => _CategoryFilterModalState();
}

class _CategoryFilterModalState extends State<CategoryFilterModal> {
  String? _tempSelectedLargeName; // ID → 이름
  List<CategorySmall> _smallCategories = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedLargeName = widget.selectedLargeName;
    _loadSmallCategories();
  }

  void _loadSmallCategories() {
    final genders = CategoryData.getGenders();
    
    // 전체 선택 시 모든 소분류 표시 (중복 제거)
    if (_tempSelectedLargeName == null) {
      final Map<String, CategorySmall> uniqueSmalls = {};
      for (final gender in genders) {
        if (widget.selectedGender != null && gender.name != widget.selectedGender) {
          continue;
        }
        for (final large in gender.larges) {
          for (final small in large.smalls) {
            // 이름을 키로 사용하여 중복 제거
            if (!uniqueSmalls.containsKey(small.name)) {
              uniqueSmalls[small.name] = small;
            }
          }
        }
      }
      setState(() {
        _smallCategories = uniqueSmalls.values.toList();
      });
      return;
    }

    // 특정 대분류 선택 시 해당 소분류만 표시
    for (final gender in genders) {
      if (widget.selectedGender != null && gender.name != widget.selectedGender) {
        continue;
      }
      
      for (final large in gender.larges) {
        if (large.name == _tempSelectedLargeName) {
          setState(() {
            _smallCategories = large.smalls;
          });
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final genders = CategoryData.getGenders();
    final List<CategoryLarge> largeCategories = [];
    
    if (widget.selectedGender != null) {
      // 특정 성별 선택 시
      final gender = genders.firstWhere(
        (g) => g.name == widget.selectedGender,
        orElse: () => genders.first,
      );
      largeCategories.addAll(gender.larges);
    } else {
      // "전체" 선택 시 - 대분류 중복 제거
      final Map<String, CategoryLarge> uniqueLarges = {};
      for (final gender in genders) {
        for (final large in gender.larges) {
          // 이름을 키로 사용하여 중복 제거 (같은 이름의 대분류는 한 번만)
          if (!uniqueLarges.containsKey(large.name)) {
            uniqueLarges[large.name] = large;
          }
        }
      }
      largeCategories.addAll(uniqueLarges.values);
    }

    return FilterModalWrapper(
      title: '카테고리',
      onApply: widget.onApply,
      onCancel: widget.onCancel,
      filterTags: widget.filterTags,
      onRemoveTag: widget.onRemoveTag,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 왼쪽: 대분류 탭
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // 전체 탭
                  InkWell(
                    onTap: () {
                      setState(() {
                        _tempSelectedLargeName = null;
                      });
                      _loadSmallCategories(); // 모든 소분류 로드
                      widget.onLargeChanged(null);
                      widget.onSmallChanged(null);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _tempSelectedLargeName == null ? Colors.white : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: _tempSelectedLargeName == null ? const Color(0xFF476A62) : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        '전체',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _tempSelectedLargeName == null ? FontWeight.w700 : FontWeight.w400,
                          color: _tempSelectedLargeName == null ? const Color(0xFF476A62) : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  // 대분류 탭들
                  ...largeCategories.map((large) {
                    final isSelected = _tempSelectedLargeName == large.name;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _tempSelectedLargeName = large.name;
                          _loadSmallCategories();
                        });
                        widget.onLargeChanged(large.name);
                        widget.onSmallChanged(null);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: isSelected ? const Color(0xFF476A62) : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          large.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? const Color(0xFF476A62) : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // 오른쪽: 소분류 체크박스
          Expanded(
            flex: 3,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                    // 전체 옵션
                    _buildCheckboxTile(
                      label: '전체',
                      value: null,
                      isSelected: widget.selectedSmallName == null,
                      onChanged: () => widget.onSmallChanged(null),
                    ),
                    ..._smallCategories.map((small) {
                      return _buildCheckboxTile(
                        label: small.name,
                        value: small.name,
                        isSelected: widget.selectedSmallName == small.name,
                        onChanged: () => widget.onSmallChanged(small.name),
                      );
                    }),
              ],
            ),
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
      child: Container(
        height: 40, // 대분류 탭과 동일한 높이
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onChanged(),
                activeColor: const Color(0xFF476A62),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
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

