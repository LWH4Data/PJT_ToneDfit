import 'package:flutter/material.dart';
import 'gender_tag_list.dart';
import '../../domain/entities/gender.dart';

/// @deprecated Use [GenderTagList] instead
@Deprecated('Use GenderTagList instead')
class CategoryLargeTagList extends StatelessWidget {
  final List<Gender> categories;
  final Gender? selectedCategory;
  final Function(Gender?)? onCategorySelected;

  const CategoryLargeTagList({
    super.key,
    required this.categories,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GenderTagList(
      genders: categories,
      selectedGender: selectedCategory,
      onGenderSelected: onCategorySelected,
    );
  }
}
