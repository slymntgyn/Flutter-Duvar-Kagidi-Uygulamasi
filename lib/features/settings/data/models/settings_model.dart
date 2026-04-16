import 'package:senseriduvarkagidi/features/settings/domain/entities/app_settings.dart';

/// Sunucudan gelen ham ayar ciftlerini AppSettings'e donusturur.
class SettingsModel {
  /// Sunucudan gelen [{adi: "...", deger: "..."}, ...] formatindaki
  /// listeyi AppSettings entity'sine donusturur.
  static AppSettings fromSettingsList(List<Map<String, dynamic>> list) {
    String getValue(String key) {
      for (final item in list) {
        final adi = (item['adi'] ?? item['ADI'] ?? '').toString();
        if (adi == key) {
          return (item['deger'] ?? item['DEGER'] ?? '').toString();
        }
      }
      return '';
    }

    String getFirstNonEmptyValue(List<String> keys) {
      for (final key in keys) {
        final value = getValue(key).trim();
        if (value.isNotEmpty) {
          return value;
        }
      }
      return '';
    }

    bool getBool(String key) {
      final v = getValue(key);
      return v == 'E' || v == '1' || v.toLowerCase() == 'true';
    }

    int getInt(String key) => int.tryParse(getValue(key)) ?? 0;

    int getAiLimit() => getInt('AI DUVAR KAĞIDI URETME LIMIT');

    final aiProvider = getFirstNonEmptyValue(
      const ['AI_PROVIDER', 'AI PROVIDER'],
    ).toLowerCase();
    final aiApiKey = getFirstNonEmptyValue(
      const ['AI_API_KEY', 'AI API KEY', 'OPENAI API KEY'],
    );
    final aiModel = getFirstNonEmptyValue(
      const [
        'AI_DUVAR_KAGIDI_URETME_MODEL',
        'AI DUVAR KAGIDI URETME MODEL',
        'OPENAI MODEL',
      ],
    );

    return AppSettings(
      imageServerUrl: getValue('RESIM SUNUCUSU'),
      isMaintenanceMode: getBool('BAKIM VAR MI'),
      isRewardedAdEnabled: getBool('ODULLU REKLAM ACIK MI'),
      rewardedAdId: getValue('ODULLU REKLAM ID'),
      bannerAdId: getValue('BANNER REKLAM ID'),
      isBannerAdEnabled: getBool('BANNER REKLAM ACIK MI'),
      telegramLink: getValue('TELEGRAM BUTON LINKI'),
      aiApiKey: aiApiKey,
      aiDailyLimit: getAiLimit(),
      aiModel: aiModel,
      openAiApiKey: aiApiKey,
      openAiModel: aiModel.isNotEmpty ? aiModel : 'dall-e-3',
      aiProvider: aiProvider.isNotEmpty ? aiProvider : 'openai',
    );
  }
}
