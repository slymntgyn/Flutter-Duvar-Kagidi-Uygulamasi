import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/core/network/network_info.dart';
import 'package:senseriduvarkagidi/core/storage/local_storage.dart';
import 'package:senseriduvarkagidi/core/theme/app_theme.dart';
import 'package:senseriduvarkagidi/core/theme/theme_provider.dart';
import 'package:senseriduvarkagidi/core/utils/device_utils.dart';

import 'package:senseriduvarkagidi/features/wallpaper/data/repositories/wallpaper_repository_impl.dart';
import 'package:senseriduvarkagidi/features/wallpaper/data/repositories/category_repository_impl.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/repositories/wallpaper_repository.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/repositories/category_repository.dart';
import 'package:senseriduvarkagidi/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:senseriduvarkagidi/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:senseriduvarkagidi/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:senseriduvarkagidi/features/settings/domain/repositories/settings_repository.dart';
import 'package:senseriduvarkagidi/features/user/data/repositories/user_repository_impl.dart';
import 'package:senseriduvarkagidi/features/user/domain/repositories/user_repository.dart';

import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/features/ai_generation/data/services/openai_ai_service.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/services/ai_image_service.dart';
import 'package:senseriduvarkagidi/features/settings/domain/entities/app_settings.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';

// ==================== Core ====================

/// SharedPreferences instance. Uygulama baslatilirken override edilir.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'sharedPreferencesProvider must be overridden in ProviderScope');
});

/// Yerel depolama abstraction'i.
final localStorageProvider = Provider<LocalStorage>((ref) {
  return SharedPrefsStorage(ref.read(sharedPreferencesProvider));
});

/// Merkezi HTTP istemcisi.
final dioClientProvider = Provider<DioClient>((ref) => DioClient());

/// Ag baglanti durumu.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

// ==================== Theme ====================

/// Tema yonetimi provider'i.
final themeProvider =
    StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier(ref.read(localStorageProvider));
});

// ==================== Device ====================

/// Cihaz ID'si. Bir kez hesaplanir ve cache'lenir.
final deviceIdProvider = FutureProvider<String>((ref) async {
  return DeviceUtils.getDeviceId(ref.read(localStorageProvider));
});

// ==================== Settings ====================

/// Ayarlar repository.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.read(dioClientProvider));
});

/// Uygulama ayarlari. Asenkron olarak yuklenir.
final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final repo = ref.read(settingsRepositoryProvider);
  final result = await repo.getSettings();
  return switch (result) {
    Success(:final data) => data,
    Error(:final failure) => throw Exception(failure.message),
  };
});

// ==================== Repositories ====================

/// Duvar kagidi repository.
final wallpaperRepositoryProvider = Provider<WallpaperRepository>((ref) {
  return WallpaperRepositoryImpl(ref.read(dioClientProvider));
});

/// Kategori repository.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.read(dioClientProvider));
});

/// Favori repository.
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(ref.read(dioClientProvider));
});

/// Kullanici repository.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(ref.read(dioClientProvider));
});

// ==================== AI Service ====================

/// AI gorsel uretim servisi - OpenAI DALL-E kullanir.
final aiImageServiceProvider = Provider<AIImageService>((ref) {
  final settings = ref.watch(appSettingsProvider).valueOrNull;

  if (settings == null || settings.openAiApiKey.isEmpty) {
    // API key henuz yuklenmedi veya tanimli degil
    return _EmptyAIService();
  }

  return OpenAIAIService(
    dioClient: ref.read(dioClientProvider),
    apiKey: settings.openAiApiKey,
    model: settings.openAiModel.isNotEmpty ? settings.openAiModel : 'dall-e-3',
  );
});

/// API key olmadigi durum icin bos servis.
class _EmptyAIService implements AIImageService {
  @override
  String get serviceId => 'none';

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<Uint8List> generateImage(dynamic request) async {
    throw const AIServiceException('OpenAI API anahtari tanimli degil');
  }
}
