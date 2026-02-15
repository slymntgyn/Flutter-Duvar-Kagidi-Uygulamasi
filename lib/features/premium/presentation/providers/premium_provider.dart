import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/features/premium/domain/entities/premium_status.dart';

/// Premium durum yonetimi provider'i.
final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumStatus>((ref) {
  final storage = ref.read(localStorageProvider);
  return PremiumNotifier(storage);
});

class PremiumNotifier extends StateNotifier<PremiumStatus> {
  final dynamic _storage;

  static const _keyPremiumTier = 'premium_tier';
  static const _keyDailyUsed = 'ai_daily_used';
  static const _keyLastUsedDate = 'ai_last_used_date';

  PremiumNotifier(this._storage) : super(const PremiumStatus()) {
    _load();
  }

  Future<void> _load() async {
    final tierStr = await _storage.getString(_keyPremiumTier);
    final dailyUsed = await _storage.getInt(_keyDailyUsed);
    final lastDate = await _storage.getString(_keyLastUsedDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final tier = tierStr == 'pro' ? PremiumTier.pro : PremiumTier.free;
    final usedToday = (lastDate == today) ? (dailyUsed ?? 0) : 0;

    if (lastDate != today) {
      await _storage.setInt(_keyDailyUsed, 0);
      await _storage.setString(_keyLastUsedDate, today);
    }

    state = PremiumStatus(
      tier: tier,
      dailyAiLimit: tier == PremiumTier.pro ? 999 : 3,
      dailyAiUsed: usedToday,
      canUseProStyles: tier == PremiumTier.pro,
      adFree: tier == PremiumTier.pro,
    );
  }

  /// AI kullanimi sayacini artir.
  Future<void> incrementUsage() async {
    final newUsed = state.dailyAiUsed + 1;
    state = state.copyWith(dailyAiUsed: newUsed);
    await _storage.setInt(_keyDailyUsed, newUsed);

    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _storage.setString(_keyLastUsedDate, today);
  }

  /// Pro'ya yukselt (satin alma sonrasi).
  Future<void> upgradeToPro() async {
    state = PremiumStatus.pro();
    await _storage.setString(_keyPremiumTier, 'pro');
  }

  /// Pro'dan dusur (iptal veya test icin).
  Future<void> downgradeToFree() async {
    state = PremiumStatus.free();
    await _storage.setString(_keyPremiumTier, 'free');
  }

  /// Gunluk sayaci sifirla.
  Future<void> resetDailyUsage() async {
    state = state.copyWith(dailyAiUsed: 0);
    await _storage.setInt(_keyDailyUsed, 0);
  }

  /// Gunluk limiti sunucu ayarlarindan guncelle.
  void updateDailyLimit(int limit) {
    state = state.copyWith(dailyAiLimit: limit);
  }
}
