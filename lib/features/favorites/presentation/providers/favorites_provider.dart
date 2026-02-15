import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';

/// Favori resim ID'leri provider'i.
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<int>>(
        (ref) => FavoritesNotifier(ref));

class FavoritesNotifier extends StateNotifier<List<int>> {
  final Ref _ref;

  FavoritesNotifier(this._ref) : super([]);

  /// Baslangicta favori listesini yukler.
  void loadFavorites(List<int> favoriteIds) {
    state = List.from(favoriteIds);
  }

  /// Resmi favorilere ekler veya cikarir (toggle).
  Future<void> toggleFavorite(String deviceId, int imageId) async {
    final repo = _ref.read(favoritesRepositoryProvider);
    final result = await repo.toggleFavorite(deviceId, imageId);

    if (result is Success) {
      if (state.contains(imageId)) {
        state = state.where((id) => id != imageId).toList();
      } else {
        state = [...state, imageId];
      }
    }
  }

  /// Resmin favori olup olmadigini kontrol eder.
  bool isFavorite(int imageId) => state.contains(imageId);
}
