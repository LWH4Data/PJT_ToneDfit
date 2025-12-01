/// 색상 엔티티
class ColorEntity {
  final String id;
  final String name;
  final String? hexCode; // "기타"의 경우 null

  const ColorEntity({
    required this.id,
    required this.name,
    this.hexCode,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
