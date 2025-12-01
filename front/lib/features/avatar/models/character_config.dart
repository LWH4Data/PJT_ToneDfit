import 'package:flutter/material.dart';
import '../assets/character_paths.dart';

/// 캐릭터 구성 모델
class CharacterConfig {
  /// 반드시 포함: head는 고정(변경 불가). 경로는 상수로만 사용.
  final String headPath;
  
  /// body-top 필수
  final String topPath;
  
  /// body-outer 선택(없으면 null)
  final String? outerPath;
  
  /// bottom 필수
  final String bottomPath;
  
  /// foot 필수
  final String footPath;

  /// 색상 정보 (null이면 원본 색상 유지)
  final Color? topColor;
  final Color? outerColor;
  final Color? bottomColor;
  final Color? footColor;

  /// BlendMode 설정 (색상 적용 방식)
  final BlendMode colorBlendMode;

  const CharacterConfig({
    this.headPath = CharacterPaths.head,
    required this.topPath,
    this.outerPath,
    required this.bottomPath,
    required this.footPath,
    this.topColor,
    this.outerColor,
    this.bottomColor,
    this.footColor,
    this.colorBlendMode = BlendMode.multiply, // 기본값: multiply
  });

  /// 기본 구성으로 생성
  factory CharacterConfig.defaults() => const CharacterConfig(
        topPath: CharacterPaths.defaultTop,
        bottomPath: CharacterPaths.defaultBottom,
        footPath: CharacterPaths.defaultFoot,
      );

  /// 일부 속성만 변경한 새 인스턴스 생성
  CharacterConfig copyWith({
    String? topPath,
    String? outerPath,
    String? bottomPath,
    String? footPath,
    Color? topColor,
    Color? outerColor,
    Color? bottomColor,
    Color? footColor,
    BlendMode? colorBlendMode,
    bool clearTopColor = false,
    bool clearOuterColor = false,
    bool clearBottomColor = false,
    bool clearFootColor = false,
  }) {
    return CharacterConfig(
      headPath: headPath, // 고정
      topPath: topPath ?? this.topPath,
      outerPath: outerPath ?? this.outerPath,
      bottomPath: bottomPath ?? this.bottomPath,
      footPath: footPath ?? this.footPath,
      topColor: clearTopColor ? null : (topColor ?? this.topColor),
      outerColor: clearOuterColor ? null : (outerColor ?? this.outerColor),
      bottomColor: clearBottomColor ? null : (bottomColor ?? this.bottomColor),
      footColor: clearFootColor ? null : (footColor ?? this.footColor),
      colorBlendMode: colorBlendMode ?? this.colorBlendMode,
    );
  }
}

