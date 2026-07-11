import 'package:senseriduvarkagidi/core/constants/api_constants.dart';

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

  // NVIDIA AI gorsel uretim ayarlari
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
    this.aiModel = ApiConstants.defaultNvidiaModel,
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
    aiModel: ApiConstants.defaultNvidiaModel,
  );

  AppSettings copyWith({
    String? imageServerUrl,
    bool? isMaintenanceMode,
    bool? isRewardedAdEnabled,
    String? rewardedAdId,
    String? bannerAdId,
    bool? isBannerAdEnabled,
    String? telegramLink,
    String? aiApiKey,
    int? aiDailyLimit,
    String? aiModel,
  }) {
    return AppSettings(
      imageServerUrl: imageServerUrl ?? this.imageServerUrl,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      isRewardedAdEnabled: isRewardedAdEnabled ?? this.isRewardedAdEnabled,
      rewardedAdId: rewardedAdId ?? this.rewardedAdId,
      bannerAdId: bannerAdId ?? this.bannerAdId,
      isBannerAdEnabled: isBannerAdEnabled ?? this.isBannerAdEnabled,
      telegramLink: telegramLink ?? this.telegramLink,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiDailyLimit: aiDailyLimit ?? this.aiDailyLimit,
      aiModel: aiModel ?? this.aiModel,
    );
  }
}
