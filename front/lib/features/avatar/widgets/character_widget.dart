import 'package:flutter/material.dart';
import '../models/character_config.dart';

/// 1024×1024 투명 배경 PNG를 전제로 레이어를 쌓아 렌더링합니다.
/// 레이어 순서(하단→상단): foot → bottom → body.top → body.outer → head
class CharacterWidget extends StatelessWidget {
  /// 화면에서의 출력 크기. null이면 부모 제약에 맞춰 1:1 비율 유지
  final double? size;
  
  /// 필수 섹션을 포함한 현재 선택 상태
  final CharacterConfig config;

  /// 이미지 해상도 1024×1024 기준으로 동일 위치를 가정합니다.
  /// 각 PNG는 같은 캔버스 사이즈(1024×1024)와 투명 배경이어야 합니다.
  const CharacterWidget({
    super.key,
    this.size,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      fit: StackFit.expand,
      children: [
        // ① foot (bottom보다 아래)
        _img(config.footPath, color: config.footColor, blendMode: config.colorBlendMode),
        // ② bottom
        _img(config.bottomPath, color: config.bottomColor, blendMode: config.colorBlendMode),
        // ③ body.top
        _img(config.topPath, color: config.topColor, blendMode: config.colorBlendMode),
        // ④ body.outer (있을 때만)
        if (config.outerPath != null && config.outerPath!.isNotEmpty)
          _img(config.outerPath!, color: config.outerColor, blendMode: config.colorBlendMode),
        // ⑤ head (맨 위)
        _img(config.headPath),
      ],
    );

    // 1:1 비율 유지. size 지정 시 정사각으로 고정, 미지정 시 부모 제약 내에서 1:1
    if (size != null) {
      return SizedBox(
        width: size,
        height: size,
        child: child,
      );
    }
    return AspectRatio(aspectRatio: 1, child: child);
  }

  Widget _img(String assetPath, {Color? color, BlendMode blendMode = BlendMode.multiply}) {
    assert(assetPath.isNotEmpty, 'assetPath must not be empty.');
    
    Widget image = Image.asset(
      assetPath,
      fit: BoxFit.contain, // 동일 캔버스 기준이므로 contain으로 안전
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
      errorBuilder: (context, error, stackTrace) {
        // 이미지 로드 실패 시 디버그 표시
        return Container(
          color: Colors.transparent,
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.red),
          ),
        );
      },
    );

    // 색상이 지정된 경우 ColorFiltered 적용
    if (color != null) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(
          color,
          blendMode, // 설정된 BlendMode 사용
        ),
        child: image,
      );
    }

    return image;
  }
}

