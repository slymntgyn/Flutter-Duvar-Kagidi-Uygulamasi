import 'package:senseriduvarkagidi/features/settings/domain/entities/app_settings.dart';

/// Sunucudan gelen ham ayar ciftlerini AppSettings'e donusturur.
class SettingsModel {
  /// Sunucudan gelen [{adi: "...", deger: "..."}, ...] formatindaki
  /// listeyi AppSettings entity'sine donusturur.
  static AppSettings fromSettingsList(List<Map<String, dynamic>> list) {
    String getValue(String key) {
      for (final item in list) {
        final adi = (item['adi'] ?? item['ADI'] ?? '').toString();
        if (adi == key) return (item['deger'] ?? item['DEGER'] ?? '').toString();
      }
      return '';
    }

    bool getBool(String key) {
      final v = getValue(key);
      return v == 'E' || v == '1' || v.toLowerCase() == 'true';
    }

    int getInt(String key) => int.tryParse(getValue(key)) ?? 0;

    return AppSettings(
      imageServerUrl: getValue('RESIM SUNUCUSU'),
      isMaintenanceMode: getBool('BAKIM VAR MI'),
      isRewardedAdEnabled: getBool('ODULLU REKLAM ACIK MI'),
      rewardedAdId: getValue('ODULLU REKLAM ID'),
      bannerAdId: getValue('BANNER REKLAM ID'),
      isBannerAdEnabled: getBool('BANNER REKLAM ACIK MI'),
      telegramLink: getValue('TELEGRAM BUTON LINKI'),
      // OpenRouter
      aiApiKey: getValue('AI API KEY'),
      aiDailyLimit: getInt('AI DUVAR KAGIDI URETME LIMIT'),
      aiModel: getValue('AI DUVAR KAGIDI URETME MODEL'),
      // OpenAI
      openAiApiKey: getValue('OPENAI API KEY'),
      openAiModel: getValue('OPENAI MODEL').isNotEmpty
          ? getValue('OPENAI MODEL')
          : 'dall-e-3',
      // Provider secimi: 'openrouter' veya 'openai'
      aiProvider: getValue('AI PROVIDER').isNotEmpty
          ? getValue('AI PROVIDER')
          : 'openrouter',
    );
  }
}
