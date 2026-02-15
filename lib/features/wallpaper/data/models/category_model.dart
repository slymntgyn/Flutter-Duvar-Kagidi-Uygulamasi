import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/category.dart';

/// Category data modeli.
/// JSON serialization yetenegi ekler.
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.imagePath,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['kategori'] as String? ?? '',
      imagePath: json['kategorI_RESMI'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kategori': name,
        'kategorI_RESMI': imagePath,
      };
}
