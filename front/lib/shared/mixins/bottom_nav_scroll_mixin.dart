import 'package:flutter/material.dart';

/// 하단 네비게이션 및 대분류 태그 스크롤 애니메이션 Mixin
/// 
/// 스크롤 방향에 따라 하단 네비게이션과 대분류 태그를 자동으로 숨기거나 표시합니다.
/// - 스크롤 내릴 때: 하단 네비게이션 및 대분류 태그 숨김
/// - 스크롤 올릴 때: 하단 네비게이션 및 대분류 태그 표시
mixin BottomNavScrollMixin<T extends StatefulWidget> on State<T> {
  // 애니메이션 관련
  double _previousScrollOffset = 0.0; // 이전 스크롤 위치
  double _scrollOpacity = 1.0; // 투명도 (0~1)
  bool _isScrollingDown = false; // 스크롤 방향
  
  /// 투명도 getter (하단 네비게이션 및 대분류 태그 공통)
  double get scrollOpacity => _scrollOpacity;
  
  /// 하단 네비게이션 투명도 getter (호환성)
  double get navOpacity => _scrollOpacity;
  
  /// 스크롤 위치에 따른 하단 네비게이션 bottom 위치 계산
  /// 
  /// [opacity]: 투명도 (0~1)
  /// Returns: bottom 위치 (opacity가 낮을수록 아래로 이동)
  double getNavBottom(double opacity) {
    // opacity가 낮을수록 아래로 이동 (85px만큼 아래로)
    return -(85.0 * (1.0 - opacity));
  }
  
  /// 스크롤 위치에 따른 대분류 태그 top 위치 계산
  /// 
  /// [baseY]: 기본 Y 위치
  /// [opacity]: 투명도 (0~1)
  /// Returns: top 위치 (opacity가 낮을수록 아래로 이동)
  double getTagTop(double baseY, double opacity) {
    // opacity가 낮을수록 아래로 이동 (100px만큼 아래로)
    return baseY + (100.0 * (1.0 - opacity));
  }
  
  /// 스크롤 방향에 따라 하단 네비게이션 및 대분류 태그 표시/숨김 처리
  /// 
  /// [currentOffset]: 현재 스크롤 위치
  /// [minDelta]: 최소 스크롤 변화량 (기본값: 5.0)
  void handleBottomNavScroll(double currentOffset, {double minDelta = 5.0}) {
    if (!mounted) return;
    
    final delta = currentOffset - _previousScrollOffset;
    
    // 스크롤 방향 감지 (최소 이동 거리 이상일 때만)
    if (delta.abs() > minDelta) {
      final isScrollingDown = delta > 0;
      
      if (isScrollingDown != _isScrollingDown) {
        _isScrollingDown = isScrollingDown;
        
        // 스크롤 방향에 따라 opacity 애니메이션
        if (_isScrollingDown) {
          // 스크롤 내릴 때: 숨김 (opacity 0)
          if (_scrollOpacity > 0) {
            setState(() {
              _scrollOpacity = 0.0;
            });
          }
        } else {
          // 스크롤 올릴 때: 표시 (opacity 1)
          if (_scrollOpacity < 1) {
            setState(() {
              _scrollOpacity = 1.0;
            });
          }
        }
      }
      
      _previousScrollOffset = currentOffset;
    }
  }
  
  /// 스크롤 애니메이션 초기 상태로 리셋
  void resetBottomNavScroll() {
    if (mounted) {
      setState(() {
        _previousScrollOffset = 0.0;
        _scrollOpacity = 1.0;
        _isScrollingDown = false;
      });
    }
  }
}

