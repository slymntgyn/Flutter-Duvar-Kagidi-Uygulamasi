/// Duvar kagidi gorseli entity'si.
/// Pure Dart - Flutter bagimliligi yoktur.
class WallpaperImage {
  final int id;
  final String path;
  final List<int> categoryIds;
  final bool isPro;

  const WallpaperImage({
    required this.id,
    required this.path,
    required this.categoryIds,
    this.isPro = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WallpaperImage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

