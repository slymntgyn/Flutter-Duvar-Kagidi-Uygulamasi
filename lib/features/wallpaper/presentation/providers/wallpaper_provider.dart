import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_image.dart';

/// Duvar kagitlari listesi provider'i.
final wallpapersProvider =
    AsyncNotifierProvider<WallpapersNotifier, List<WallpaperImage>>(
        WallpapersNotifier.new);

class WallpapersNotifier extends AsyncNotifier<List<WallpaperImage>> {
  @override
  Future<List<WallpaperImage>> build() async {
    final repo = ref.read(wallpaperRepositoryProvider);
    final result = await repo.getWallpapers();
    return switch (result) {
      Success(:final data) => data,
      Error(:final failure) => throw Exception(failure.message),
    };
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
