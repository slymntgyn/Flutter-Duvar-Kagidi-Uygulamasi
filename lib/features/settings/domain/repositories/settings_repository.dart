import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/features/settings/domain/entities/app_settings.dart';

/// Ayarlar repository interface'i.
abstract class SettingsRepository {
  /// Sunucudan uygulama ayarlarini getirir.
  Future<Result<AppSettings>> getSettings();
}

