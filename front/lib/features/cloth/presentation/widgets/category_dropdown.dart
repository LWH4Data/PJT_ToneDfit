import 'package:flutter/material.dart';
import '../../../category/domain/entities/category_large.dart';
import '../../../category/domain/entities/category_small.dart';
import '../../data/category_data.dart';
import 'filter_dropdown.dart';

/// 카테고리 선택 드롭다운 위젯 (대분류 + 소분류)
class CategoryDropdown extends StatefulWidget {
  final String? selectedGender;
  final String? selectedLargeId;
  final String? selectedSmallId;
  final ValueChanged<String?>? onLargeChanged;
  final ValueChanged<String?>? onSmallChanged;

  const CategoryDropdown({
    super.key,
    this.selectedGender,
    this.selectedLargeId,
    this.selectedSmallId,
    this.onLargeChanged,
    this.onSmallChanged,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  List<CategoryLarge> _largeCategories = [];
  List<CategorySmall> _smallCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void didUpdateWidget(CategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGender != widget.selectedGender ||
        oldWidget.selectedLargeId != widget.selectedLargeId) {
      _loadCategories();
    }
  }

  void _loadCategories() {
    final genders = CategoryData.getGenders();
    
    // 성별에 따른 대분류 가져오기
    if (widget.selectedGender != null) {
      final gender = genders.firstWhere(
        (g) => g.name == widget.selectedGender,
        orElse: () => genders[0],
      );
      setState(() {
        _largeCategories = gender.larges;
      });
    } else {
      setState(() {
        _largeCategories = [];
      });
    }

    // 대분류에 따른 소분류 가져오기
    if (widget.selectedLargeId != null && _largeCategories.isNotEmpty) {
      final large = _largeCategories.firstWhere(
        (l) => l.id == widget.selectedLargeId,
        orElse: () => _largeCategories[0],
      );
      setState(() {
        _smallCategories = large.smalls;
      });
    } else {
      setState(() {
        _smallCategories = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 대분류 선택
        FilterDropdown(
          label: '',
          value: widget.selectedLargeId,
          placeholder: '대분류 선택',
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('전체', style: TextStyle(fontSize: 14)),
            ),
            ..._largeCategories.map((large) {
              return DropdownMenuItem<String>(
                value: large.id,
                child: Text(
                  large.name,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }),
          ],
          onChanged: (value) {
            widget.onLargeChanged?.call(value);
            // 대분류 변경 시 소분류 초기화
            widget.onSmallChanged?.call(null);
          },
        ),
        const SizedBox(height: 16),
        // 소분류 선택 (대분류가 선택되었을 때만 표시)
        if (widget.selectedLargeId != null && _smallCategories.isNotEmpty)
          FilterDropdown(
            label: '',
            value: widget.selectedSmallId,
            placeholder: '소분류 선택',
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('전체', style: TextStyle(fontSize: 14)),
              ),
              ..._smallCategories.map((small) {
                return DropdownMenuItem<String>(
                  value: small.id,
                  child: Text(
                    small.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
            ],
            onChanged: widget.onSmallChanged,
          ),
      ],
    );
  }
}



