import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/features/premium/domain/entities/premium_status.dart';

/// Premium durum yonetimi provider'i.
final premiumProvider =
    StateNotifierProvider<PremiumNotifier, PremiumStatus>((ref) {
  return PremiumNotifier(ref);
});

class PremiumNotifier extends StateNotifier<PremiumStatus> {
  final Ref _ref;

  static const _keyPremiumTier = 'premium_tier';
  static const _keyDailyUsed = 'ai_daily_used';
  static const _keyLastUsedDate = 'ai_last_used_date';

  PremiumNotifier(this._ref) : super(const PremiumStatus()) {
    _loadLocal();
    _syncWithServer();
  }

  // -------------------- Yerel Yukleme --------------------

  Future<void> _loadLocal() async {
    final storage = _ref.read(localStorageProvider);
    final tierStr = await storage.getString(_keyPremiumTier);
    final dailyUsed = await storage.getInt(_keyDailyUsed);
    final lastDate = await storage.getString(_keyLastUsedDate);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final tier = tierStr == 'pro' ? PremiumTier.pro : PremiumTier.free;
    final usedToday = (lastDate == today) ? (dailyUsed ?? 0) : 0;

    if (lastDate != today) {
      await storage.setInt(_keyDailyUsed, 0);
      await storage.setString(_keyLastUsedDate, today);
    }

    state = PremiumStatus(
      tier: tier,
      dailyAiLimit: 3,
      dailyAiUsed: usedToday,
      canUseProStyles: tier == PremiumTier.pro,
      adFree: tier == PremiumTier.pro,
    );
  }

  // -------------------- Sunucu Senkronizasyonu --------------------

  /// Sunucudan premium durumu ve AI kullanimi ceker.
  Future<void> _syncWithServer() async {
    try {
      final deviceId = await _ref.read(deviceIdProvider.future);
      if (deviceId.isEmpty) return;

      final dio = _ref.read(dioClientProvider);
      final response =
          await dio.get(ApiConstants.getPremiumStatus(deviceId));

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final isPremium = data['isPremium'] as bool? ?? false;
        final dailyCount = data['aiDailyCount'] as int? ?? 0;
        final dailyLimit = data['dailyLimit'] as int? ?? 3;

        final tier = isPremium ? PremiumTier.pro : PremiumTier.free;

        // Yerel storage'i sunucu verisiyle guncelle
        final storage = _ref.read(localStorageProvider);
        await storage.setString(_keyPremiumTier, isPremium ? 'pro' : 'free');
        await storage.setInt(_keyDailyUsed, dailyCount);
        final today = DateTime.now().toIso8601String().substring(0, 10);
        await storage.setString(_keyLastUsedDate, today);

        state = PremiumStatus(
          tier: tier,
          dailyAiLimit: dailyLimit,
          dailyAiUsed: dailyCount,
          canUseProStyles: isPremium,
          adFree: isPremium,
        );
      }
    } catch (_) {
      // Sunucu hatasi yerel veriyi etkilemesin
    }
  }

  // -------------------- AI Kullanim Takibi --------------------

  /// AI kullanimi artir: yerel + sunucu.
  Future<void> incrementUsage() async {
    final newUsed = state.dailyAiUsed + 1;
    state = state.copyWith(dailyAiUsed: newUsed);

    final storage = _ref.read(localStorageProvider);
    await storage.setInt(_keyDailyUsed, newUsed);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await storage.setString(_keyLastUsedDate, today);

    // Sunucuda logla
    try {
      final deviceId = await _ref.read(deviceIdProvider.future);
      if (deviceId.isNotEmpty) {
        final dio = _ref.read(dioClientProvider);
        await dio.post(ApiConstants.logAiGeneration(deviceId));
      }
    } catch (_) {}
  }

  // -------------------- Premium Yonetimi --------------------

  /// Pro'ya yukselt (satin alma sonrasi).
  Future<void> upgradeToPro() async {
    state = PremiumStatus.pro();
    final storage = _ref.read(localStorageProvider);
    await storage.setString(_keyPremiumTier, 'pro');
  }

  /// Pro'dan dusur (iptal).
  Future<void> downgradeToFree() async {
    state = PremiumStatus.free();
    final storage = _ref.read(localStorageProvider);
    await storage.setString(_keyPremiumTier, 'free');
  }

  /// Gunluk sayaci sifirla.
  Future<void> resetDailyUsage() async {
    state = state.copyWith(dailyAiUsed: 0);
    final storage = _ref.read(localStorageProvider);
    await storage.setInt(_keyDailyUsed, 0);
  }

  /// Sunucu ayarindan gunluk limiti guncelle.
  void updateDailyLimit(int limit) {
    state = state.copyWith(dailyAiLimit: limit);
  }

  /// Sunucuyu manuel olarak yenile.
  Future<void> refresh() => _syncWithServer();
}

