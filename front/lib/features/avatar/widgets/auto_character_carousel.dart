import 'dart:async';
import 'package:flutter/material.dart';

/// 10분마다 자동으로 캐릭터가 변경되는 위젯
class AutoCharacterCarousel extends StatefulWidget {
  /// 캐릭터 이미지 경로 리스트
  final List<String> characterImages;
  
  /// 캐릭터 표시 크기
  final double size;
  
  /// 자동 변경 주기 (기본값: 10분)
  final Duration changeDuration;
  
  /// 제목 표시 여부
  final bool showTitle;

  const AutoCharacterCarousel({
    super.key,
    required this.characterImages,
    this.size = 320,
    this.changeDuration = const Duration(minutes: 10),
    this.showTitle = true,
  });

  @override
  State<AutoCharacterCarousel> createState() => _AutoCharacterCarouselState();
}

class _AutoCharacterCarouselState extends State<AutoCharacterCarousel> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(widget.changeDuration, (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.characterImages.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showTitle) ...[
          const Text(
            '추천 캐릭터',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '10분마다 자동으로 변경됩니다 (${_currentIndex + 1}/${widget.characterImages.length})',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // 캐릭터 이미지 (테두리/그림자 없음)
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Image.asset(
            widget.characterImages[_currentIndex],
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      '이미지 로드 실패',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

