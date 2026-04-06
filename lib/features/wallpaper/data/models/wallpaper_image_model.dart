import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_image.dart';

/// WallpaperImage data modeli.
/// JSON serialization yetenegi ekler.
class WallpaperImageModel extends WallpaperImage {
  const WallpaperImageModel({
    required super.id,
    required super.path,
    required super.categoryIds,
    super.isPro,
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
      path: _mergeApiPath(
        (json['yol'] ?? '').toString(),
        (json['resiM_ADI'] ?? '').toString(),
      ),
      categoryIds: categoryIds,
      isPro: _parseBool(json['iS_PRO']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == '1' ||
          normalized == 'true' ||
          normalized == 'evet' ||
          normalized == 'yes';
    }
    return false;
  }

  static String _mergeApiPath(String rawPath, String rawFileName) {
    final path = rawPath.trim();
    final fileName = rawFileName.trim();

    if (path.isNotEmpty && fileName.isNotEmpty) {
      final cleanPath =
          path.endsWith('/') ? path.substring(0, path.length - 1) : path;
      final cleanFileName =
          fileName.startsWith('/') ? fileName.substring(1) : fileName;
      return '$cleanPath/$cleanFileName';
    }

    if (fileName.isNotEmpty) return fileName;
    return path;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'yol': path,
        'kategori': categoryIds.join(';'),
        'is_pro': isPro,
      };
}
