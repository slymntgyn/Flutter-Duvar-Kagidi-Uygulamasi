import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_image.dart';

/// WallpaperImage data modeli.
/// JSON serialization yetenegi ekler.
class WallpaperImageModel extends WallpaperImage {
  const WallpaperImageModel({
    required super.id,
    required super.path,
    required super.categoryIds,
  });

  factory WallpaperImageModel.fromJson(Map<String, dynamic> json) {
    final categoryStr = json['kategori'] as String? ?? '';
    final categoryIds = categoryStr
        .split(';')
        .where((s) => s.isNotEmpty)
        .map((s) => int.tryParse(s) ?? 0)
        .where((id) => id > 0)
        .toList();

    return WallpaperImageModel(
      id: json['id'] as int? ?? 0,
      path: json['yol'] as String? ?? '',
      categoryIds: categoryIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'yol': path,
        'kategori': categoryIds.join(';'),
      };
}
