import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/constants/app_constants.dart';
import 'package:senseriduvarkagidi/core/storage/local_storage.dart';
import 'package:senseriduvarkagidi/core/theme/app_theme.dart';

/// Riverpod tabanli tema yonetici.
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final LocalStorage _storage;

  ThemeNotifier(this._storage) : super(AppThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final saved = await _storage.getString(AppConstants.keyThemeMode);
    if (saved != null) {
      state = AppThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppThemeMode.light,
      );
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    await _storage.setString(AppConstants.keyThemeMode, mode.name);
  }

  Future<void> toggleTheme() async {
    final next = switch (state) {
      AppThemeMode.light => AppThemeMode.dark,
      AppThemeMode.dark => AppThemeMode.amoled,
      AppThemeMode.amoled => AppThemeMode.light,
    };
    await setTheme(next);
  }
}

