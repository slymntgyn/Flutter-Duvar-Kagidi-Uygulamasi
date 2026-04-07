import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/category.dart';

/// Kategori repository interface'i.
abstract class CategoryRepository {
  /// Tum kategorileri getirir.
  Future<Result<List<Category>>> getCategories();
}

