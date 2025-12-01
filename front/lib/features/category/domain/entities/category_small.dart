class CategorySmall {
  final String id;
  final String name;
  
  const CategorySmall({
    required this.id, 
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategorySmall && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
