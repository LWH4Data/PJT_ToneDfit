import 'package:flutter/material.dart';
import 'category_small_tag.dart';
import '../../domain/entities/category_small.dart';

class CategorySmallTagList extends StatefulWidget {
  final List<CategorySmall>? categories;
  final List<String>? tags;
  final CategorySmall? selectedCategory;
  final String? selectedTag;
  final Function(CategorySmall?)? onCategorySelected; // null이면 "전체" 선택
  final Function(String)? onTagSelected;
  final bool allowMultipleSelection;
  final bool showAllOption; // "전체" 옵션 표시 여부
  final String allOptionLabel; // "전체" 옵션 텍스트

  const CategorySmallTagList({
    super.key,
    this.categories,
    this.tags,
    this.selectedCategory,
    this.selectedTag,
    this.onCategorySelected,
    this.onTagSelected,
    this.allowMultipleSelection = false,
    this.showAllOption = true,
    this.allOptionLabel = '전체',
  }) : assert(categories != null || tags != null, 'Either categories or tags must be provided');

  @override
  State<CategorySmallTagList> createState() => _CategorySmallTagListState();
}

class _CategorySmallTagListState extends State<CategorySmallTagList> {
  CategorySmall? _selectedCategory;
  String? _selectedTag;
  Set<CategorySmall> _selectedCategories = {};
  Set<String> _selectedTags = {};
  bool _isAllSelected = false; // "전체" 선택 상태

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedTag = widget.selectedTag;
    _isAllSelected = widget.selectedCategory == null; // 초기에 선택된 카테고리가 없으면 "전체" 선택
    
    if (widget.selectedCategory != null) {
      _selectedCategories.add(widget.selectedCategory!);
    }
    if (widget.selectedTag != null) {
      _selectedTags.add(widget.selectedTag!);
    }
  }

  void _onAllTap() {
    setState(() {
      _isAllSelected = true;
      _selectedCategory = null;
      _selectedCategories.clear();
    });

    if (widget.onCategorySelected != null) {
      widget.onCategorySelected!(null); // null = "전체" 선택
    }
  }

  void _onCategoryTap(CategorySmall category) {
    setState(() {
      _isAllSelected = false;
      if (widget.allowMultipleSelection) {
        if (_selectedCategories.contains(category)) {
          _selectedCategories.remove(category);
        } else {
          _selectedCategories.add(category);
        }
      } else {
        _selectedCategory = category;
        _selectedCategories.clear();
        _selectedCategories.add(category);
      }
    });

    if (widget.onCategorySelected != null) {
      widget.onCategorySelected!(category);
    }
  }

  void _onTagTap(String tag) {
    setState(() {
      if (widget.allowMultipleSelection) {
        if (_selectedTags.contains(tag)) {
          _selectedTags.remove(tag);
        } else {
          _selectedTags.add(tag);
        }
      } else {
        _selectedTag = _selectedTag == tag ? null : tag;
        _selectedTags.clear();
        if (_selectedTag != null) {
          _selectedTags.add(_selectedTag!);
        }
      }
    });

    if (widget.onTagSelected != null) {
      widget.onTagSelected!(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        // "전체" 옵션 (CategorySmall 사용 시에만)
        if (widget.categories != null && widget.showAllOption)
          CategorySmallTag(
            label: widget.allOptionLabel,
            isSelected: _isAllSelected,
            onTap: _onAllTap,
          ),
        
                // CategorySmall 엔티티 사용
                if (widget.categories != null)
                  ...widget.categories!.map((category) {
                    final isSelected = widget.allowMultipleSelection
                      ? _selectedCategories.contains(category)
                      : _selectedCategory == category;

                    return CategorySmallTag(
                      category: category,
                      isSelected: isSelected,
                      onTap: () => _onCategoryTap(category),
                    );
                  }),

                // 기존 String 태그 사용 (하위 호환성)
                if (widget.tags != null)
                  ...widget.tags!.map((tag) {
                    final isSelected = widget.allowMultipleSelection
                      ? _selectedTags.contains(tag)
                      : _selectedTag == tag;

                    return CategorySmallTag(
                      label: tag,
                      isSelected: isSelected,
                      onTap: () => _onTagTap(tag),
                    );
                  }),
      ],
    );
  }
}






