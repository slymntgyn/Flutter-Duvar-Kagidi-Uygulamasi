import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/category.dart';

/// Category data modeli.
/// JSON serialization yetenegi ekler.
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.imagePath,
  });

  static String _firstNonEmptyString(
      Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  static int _parseId(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: _parseId(json['id']),
      name: json['kategori'] as String? ?? '',
      imagePath: _firstNonEmptyString(json, const [
        'categoryImage',
        'kategoriResmi',
        'KATEGORI_RESMI',
        'kategori_resmi',
        'resim',
        'image',
        'img',
      ]),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kategori': name,
        'categoryImage': imagePath,
      };
}
