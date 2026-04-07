import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/constants/app_constants.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';

/// Gunluk AI uretim limiti durumu.
class DailyLimitState {
  final int used;
  final int limit;
  final String lastDate;

  const DailyLimitState({
    this.used = 0,
    this.limit = AppConstants.defaultAiDailyLimit,
    this.lastDate = '',
  });

  bool get isExhausted => used >= limit;
  int get remaining => (limit - used).clamp(0, limit);
}

/// Gunluk limit provider'i.
final dailyLimitProvider =
    StateNotifierProvider<DailyLimitNotifier, DailyLimitState>(
        (ref) => DailyLimitNotifier(ref));

class DailyLimitNotifier extends StateNotifier<DailyLimitState> {
  final Ref _ref;

  DailyLimitNotifier(this._ref) : super(const DailyLimitState()) {
    _load();
  }

  Future<void> _load() async {
    final storage = _ref.read(localStorageProvider);
    final settings = _ref.read(appSettingsProvider).valueOrNull;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate =
        await storage.getString(AppConstants.keyLastAiGenDate) ?? '';

    int count = 0;
    if (lastDate == today) {
      count = await storage.getInt(AppConstants.keyAiGenCount) ?? 0;
    } else {
      // Yeni gun, sayaci sifirla
      await storage.setString(AppConstants.keyLastAiGenDate, today);
      await storage.setInt(AppConstants.keyAiGenCount, 0);
    }

    state = DailyLimitState(
      used: count,
      limit: settings?.aiDailyLimit ?? AppConstants.defaultAiDailyLimit,
      lastDate: today,
    );
  }

  Future<void> increment() async {
    final storage = _ref.read(localStorageProvider);
    final today = DateTime.now().toIso8601String().split('T')[0];
    final newCount = state.used + 1;

    await storage.setString(AppConstants.keyLastAiGenDate, today);
    await storage.setInt(AppConstants.keyAiGenCount, newCount);

    state = DailyLimitState(
      used: newCount,
      limit: state.limit,
      lastDate: today,
    );
  }

  bool canGenerate() => !state.isExhausted;
}

