import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/category.dart';

/// Kategoriler listesi provider'i.
final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
        CategoriesNotifier.new);

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() async {
    final repo = ref.read(categoryRepositoryProvider);
    final result = await repo.getCategories();
    return switch (result) {
      Success(:final data) => data,
      Error(:final failure) => throw Exception(failure.message),
    };
  }
}
