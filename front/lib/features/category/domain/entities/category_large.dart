import 'category_small.dart';

/// 대분류 카테고리 (기존 중분류가 대분류로 변경됨)
class CategoryLarge {
  final String id;
  final String name;
  final List<CategorySmall> smalls;
  
  const CategoryLarge({
    required this.id, 
    required this.name, 
    required this.smalls,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryLarge && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
