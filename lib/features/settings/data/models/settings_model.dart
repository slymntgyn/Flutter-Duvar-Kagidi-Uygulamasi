import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
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

    // NVIDIA API anahtari. Eski AI_API_KEY / OPENAI API KEY alanlari da okunur
    // (backend gecis surecinde bu alana nvapi- anahtari konulabilir).
    final aiApiKey = getFirstNonEmptyValue(
      const [
        'NVIDIA_API_KEY',
        'NVIDIA API KEY',
        'AI_API_KEY',
        'AI API KEY',
        'OPENAI API KEY',
      ],
    );
    final aiModel = getFirstNonEmptyValue(
      const [
        'AI_DUVAR_KAGIDI_URETME_MODEL',
        'AI DUVAR KAGIDI URETME MODEL',
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
      aiModel: aiModel.isNotEmpty ? aiModel : ApiConstants.defaultNvidiaModel,
    );
  }
}
