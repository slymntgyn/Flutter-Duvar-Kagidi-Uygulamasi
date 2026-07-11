import 'package:senseriduvarkagidi/model/ayarlar_model.dart';

/// Legacy ekranlarin (explore/kategori/favori/detay/splash) kullandigi
/// statik ayar deposu. Sadece hala kullanilan alanlar burada tutulur.
/// AI ayarlari yeni mimaride `appSettingsProvider` / NVIDIA servisi
/// uzerinden okunur; bu class'ta AI alani yoktur.
class LegacyAyarlar {
  static const String _fallbackImageServerUrl =
      'https://test.suleymanturan.com/resimler';

  static String imageServerUrl = "";
  static String maintenanceEnabled = "";
  static String rewardedAdsEnabled = "";
  static String rewardedAdUnitId = "";
  static String bannerAdUnitId = "";

  static void loadSettings(List<Ayarlar> list) {
    if (list.isEmpty) {
      return;
    }

    for (final item in list) {
      switch (item.adi) {
        case "RESIM SUNUCUSU":
          imageServerUrl = item.deger;
        case "BAKIM VAR MI":
          maintenanceEnabled = item.deger;
        case "ODULLU REKLAM ACIK MI":
          rewardedAdsEnabled = item.deger;
        case "ODULLU REKLAM ID":
          rewardedAdUnitId = item.deger;
        case "BANNER REKLAM ID":
          bannerAdUnitId = item.deger;
      }
    }
  }

  static String buildImageUrl(String rawPath) {
    final path = rawPath.trim();
    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final base = imageServerUrl.trim();
    final effectiveBase = base.isEmpty ? _fallbackImageServerUrl : base;

    final cleanBase = effectiveBase.endsWith('/')
        ? effectiveBase.substring(0, effectiveBase.length - 1)
        : effectiveBase;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$cleanBase/$cleanPath';
  }
}
