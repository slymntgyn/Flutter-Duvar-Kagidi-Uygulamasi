import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_image.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_location.dart';

/// Duvar kagidi repository interface'i.
/// Domain katmaninda tanimlanir, data katmaninda implement edilir.
abstract class WallpaperRepository {
  /// Tum duvar kagitlarini getirir.
  Future<Result<List<WallpaperImage>>> getWallpapers();

  /// Duvar kagidi olarak LegacyAyarlar.
  Future<Result<void>> setWallpaper(
      String imageUrl, WallpaperLocation location);

  /// Gorseli galeriye indirir.
  Future<Result<void>> downloadWallpaper(String imageUrl);

  /// Kullanici islemini loglar.
  Future<Result<void>> logAction(
      String deviceId, String action, int imageId);
}

