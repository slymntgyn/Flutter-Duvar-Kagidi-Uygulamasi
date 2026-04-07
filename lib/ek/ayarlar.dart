import 'package:senseriduvarkagidi/model/ayarlar_model.dart';

class LegacyAyarlar {
  static const String _fallbackImageServerUrl =
      'https://test.suleymanturan.com/resimler';

  static String imageServerUrl = "";
  static String maintenanceEnabled = "";
  static String rewardedAdsEnabled = "";
  static String rewardedAdUnitId = "";
  static String bannerAdUnitId = "";
  static String bannerAdsEnabled = "";
  static String telegramLink = "";
  static String aiApiKey = "";
  static String aiWallpaperLimit = "";
  static String aiWallpaperModel = "";

  static void loadSettings(List<Ayarlar> list) {
    if (list.isEmpty) {
      return;
    }

    for (var item in list) {
      if (item.adi == "RESIM SUNUCUSU") {
        imageServerUrl = item.deger;
      }
      if (item.adi == "BAKIM VAR MI") {
        maintenanceEnabled = item.deger;
      }
      if (item.adi == "ODULLU REKLAM ACIK MI") {
        rewardedAdsEnabled = item.deger;
      }
      if (item.adi == "ODULLU REKLAM ID") {
        rewardedAdUnitId = item.deger;
      }
      if (item.adi == "TELEGRAM BUTON LINKI") {
        telegramLink = item.deger;
      }
      if (item.adi == "BANNER REKLAM ID") {
        bannerAdUnitId = item.deger;
      }
      if (item.adi == "BANNER REKLAM ACIK MI") {
        bannerAdsEnabled = item.deger;
      }
      if (item.adi == "AI API KEY") {
        aiApiKey = item.deger;
      }
      if (item.adi == "AI DUVAR KAĞIGI URETME LIMIT") {
        aiWallpaperLimit = item.deger;
      }
      if (item.adi == "AI DUVAR KAĞIGI URETME MODEL") {
        aiWallpaperModel = item.deger;
      }
    }
  }

  static bool stringToBool(String sonuc) {
    if (sonuc == "E") {
      return true;
    } else {
      return false;
    }
  }

  static int stringToInt(String sonuc) {
    try {
      return int.parse(sonuc);
    } catch (error) {
      return 0;
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


