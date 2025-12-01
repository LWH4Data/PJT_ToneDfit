import 'package:flutter/material.dart';
import 'gender_tag.dart';
import '../../domain/entities/gender.dart';

/// 성별 태그 리스트
class GenderTagList extends StatelessWidget {
  final List<Gender> genders;
  final Gender? selectedGender;
  final Function(Gender?)? onGenderSelected;

  const GenderTagList({
    super.key,
    required this.genders,
    this.selectedGender,
    this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GenderTag(
      genders: genders,
      selectedGender: selectedGender,
      onGenderSelected: onGenderSelected,
    );
  }
}

