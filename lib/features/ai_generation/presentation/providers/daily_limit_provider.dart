import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/constants/app_constants.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/providers/premium_provider.dart';

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
    _ref.listen(appSettingsProvider, (_, next) {
      final int settingsLimit = next.valueOrNull?.aiDailyLimit ?? 0;
      final bool isPro = _ref.read(premiumProvider).isPro;
      _applyLimitByMembership(settingsLimit, isPro);
    });
    _ref.listen(premiumProvider, (previous, next) {
      final bool wasPro = previous?.isPro ?? false;
      final bool isPro = next.isPro;
      final int settingsLimit =
          _ref.read(appSettingsProvider).valueOrNull?.aiDailyLimit ?? 0;

      if (!wasPro && isPro) {
        unawaited(_resetDailyUsageAndApplyLimit(settingsLimit));
        return;
      }

      _applyLimitByMembership(settingsLimit, isPro);
    });
    _load();
  }

  int _resolveLimit(int settingsLimit, bool isPro) {
    if (!isPro) {
      return 0;
    }

    if (settingsLimit > 0) {
      return settingsLimit;
    }

    return AppConstants.defaultAiDailyLimit;
  }

  void _applyLimitByMembership(int settingsLimit, bool isPro) {
    final int resolvedLimit = _resolveLimit(settingsLimit, isPro);
    final int resolvedUsed = resolvedLimit == 0 ? 0 : state.used;

    if (resolvedLimit == state.limit && resolvedUsed == state.used) {
      return;
    }

    state = DailyLimitState(
      used: resolvedUsed,
      limit: resolvedLimit,
      lastDate: state.lastDate,
    );
  }

  Future<void> _resetDailyUsageAndApplyLimit(int settingsLimit) async {
    final storage = _ref.read(localStorageProvider);
    final today = DateTime.now().toIso8601String().split('T')[0];

    await storage.setString(AppConstants.keyLastAiGenDate, today);
    await storage.setInt(AppConstants.keyAiGenCount, 0);

    state = DailyLimitState(
      used: 0,
      limit: _resolveLimit(settingsLimit, true),
      lastDate: today,
    );
  }

  Future<void> _load() async {
    final storage = _ref.read(localStorageProvider);
    final settings = _ref.read(appSettingsProvider).valueOrNull;
    final bool isPro = _ref.read(premiumProvider).isPro;
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
      used: isPro ? count : 0,
      limit: _resolveLimit(settings?.aiDailyLimit ?? 0, isPro),
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
