import 'package:flutter/material.dart';
import 'gender_tag.dart';
import '../../domain/entities/gender.dart';

/// @deprecated Use [GenderTag] instead
@Deprecated('Use GenderTag instead')
class CategoryLargeTag extends StatefulWidget {
  final List<Gender> categories;
  final Gender? selectedCategory;
  final Function(Gender?)? onCategorySelected;

  const CategoryLargeTag({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  State<CategoryLargeTag> createState() => _CategoryLargeTagState();
}

@Deprecated('Use GenderTag instead')
class _CategoryLargeTagState extends State<CategoryLargeTag> {
  @override
  Widget build(BuildContext context) {
    return GenderTag(
      genders: widget.categories,
      selectedGender: widget.selectedCategory,
      onGenderSelected: widget.onCategorySelected,
    );
  }
}
