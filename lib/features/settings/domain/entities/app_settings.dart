/// Sunucudan alinan uygulama ayarlari.
/// Pure Dart - Flutter bagimliligi yoktur.
class AppSettings {
  final String imageServerUrl;
  final bool isMaintenanceMode;
  final bool isRewardedAdEnabled;
  final String rewardedAdId;
  final String bannerAdId;
  final bool isBannerAdEnabled;
  final String telegramLink;
  final String aiApiKey;
  final int aiDailyLimit;
  final String aiModel;

  const AppSettings({
    required this.imageServerUrl,
    required this.isMaintenanceMode,
    required this.isRewardedAdEnabled,
    required this.rewardedAdId,
    required this.bannerAdId,
    required this.isBannerAdEnabled,
    required this.telegramLink,
    required this.aiApiKey,
    required this.aiDailyLimit,
    required this.aiModel,
  });

  /// Bos / default ayarlar.
  static const AppSettings empty = AppSettings(
    imageServerUrl: '',
    isMaintenanceMode: false,
    isRewardedAdEnabled: false,
    rewardedAdId: '',
    bannerAdId: '',
    isBannerAdEnabled: false,
    telegramLink: '',
    aiApiKey: '',
    aiDailyLimit: 3,
    aiModel: '',
  );
}
