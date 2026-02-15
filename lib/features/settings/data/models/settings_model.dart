import 'package:senseriduvarkagidi/features/settings/domain/entities/app_settings.dart';

/// Sunucudan gelen ham ayar ciftlerini AppSettings'e donusturur.
class SettingsModel {
  /// Sunucudan gelen [{adi: "...", deger: "..."}, ...] formatindaki
  /// listeyi AppSettings entity'sine donusturur.
  static AppSettings fromSettingsList(List<Map<String, dynamic>> list) {
    String _getValue(String key) {
      for (final item in list) {
        if (item['adi'] == key) return item['deger'] as String? ?? '';
      }
      return '';
    }

    bool _getBool(String key) => _getValue(key) == 'E' || _getValue(key) == '1';

    int _getInt(String key) => int.tryParse(_getValue(key)) ?? 0;

    return AppSettings(
      imageServerUrl: _getValue('RESIM SUNUCUSU'),
      isMaintenanceMode: _getBool('BAKIM VAR MI'),
      isRewardedAdEnabled: _getBool('ODULLU REKLAM ACIK MI'),
      rewardedAdId: _getValue('ODULLU REKLAM ID'),
      bannerAdId: _getValue('BANNER REKLAM ID'),
      isBannerAdEnabled: _getBool('BANNER REKLAM ACIK MI'),
      telegramLink: _getValue('TELEGRAM BUTON LINKI'),
      aiApiKey: _getValue('AI API KEY'),
      aiDailyLimit: _getInt('AI DUVAR KAĞIGI URETME LIMIT'),
      aiModel: _getValue('AI DUVAR KAĞIGI URETME MODEL'),
    );
  }
}
