import 'package:senseriduvarkagidi/core/errors/result.dart';

/// Favori repository interface'i.
abstract class FavoritesRepository {
  /// Favorilere resim ekler/cikarir (toggle).
  Future<Result<void>> toggleFavorite(String deviceId, int imageId);
}
