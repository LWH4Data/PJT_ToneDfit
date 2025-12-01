import 'category_large.dart';

/// 성별 카테고리
class Gender {
  final String id;
  final String name;
  final List<CategoryLarge> larges; // 대분류 목록
  
  const Gender({
    required this.id, 
    required this.name, 
    required this.larges,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Gender && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

