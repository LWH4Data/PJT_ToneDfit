import 'package:flutter/material.dart';
import '../../../cloth/data/category_data.dart';

class SplashController extends ChangeNotifier {
  bool _isDataLoaded = false;
  bool _isLoading = true;
  String _loadingMessage = '데이터를 불러오는 중...';

  bool get isDataLoaded => _isDataLoaded;
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  Future<void> loadMainPageData() async {
    try {
      _updateLoadingState(true, '카테고리 데이터를 불러오는 중...');
      
      // 카테고리 데이터 로드 (실제로는 동기적이지만 비동기로 시뮬레이션)
      await Future.delayed(const Duration(milliseconds: 500));
      final genders = CategoryData.getGenders();
      
      _updateLoadingState(true, '데이터 검증 중...');
      
      // 데이터 검증
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (genders.isNotEmpty) {
        _updateLoadingState(false, '로딩 완료!');
        _isDataLoaded = true;
      } else {
        throw Exception('데이터 로딩 실패');
      }
    } catch (e) {
      _updateLoadingState(false, '로딩 실패: ${e.toString()}');
      _isDataLoaded = false;
    }
  }

  void _updateLoadingState(bool isLoading, String message) {
    _isLoading = isLoading;
    _loadingMessage = message;
    notifyListeners();
  }
}


