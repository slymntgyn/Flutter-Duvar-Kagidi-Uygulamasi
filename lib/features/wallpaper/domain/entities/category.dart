/// Kategori entity'si.
/// Pure Dart - Flutter bagimliligi yoktur.
class Category {
  final int id;
  final String name;
  final String imagePath;

  const Category({
    required this.id,
    required this.name,
    required this.imagePath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
