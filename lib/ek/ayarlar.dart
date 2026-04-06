import 'package:senseriduvarkagidi/model/Ayarlar.dart';

class ayarlar {
  static const String _fallbackImageServerUrl =
      'https://test.suleymanturan.com/resimler';

  static String resimsunucusu = "";
  static String bakimvarmi = "";
  static String odullureklamacikmi = "";
  static String odulluReklamId = "";
  static String bannerReklamId = "";
  static String bannerReklamAcikMi = "";
  static String telegramlink = "";
  static String aiapikey = "";
  static String aiDuvarKagidiUretmeLimit = "";
  static String aiDuvarKagidiUretmeModel = "";

  static void Ayarlari_Yukle(List<Ayarlar> list) {
    if (list.isEmpty) {
      return;
    }

    for (var item in list) {
      if (item.adi == "RESIM SUNUCUSU") {
        resimsunucusu = item.deger;
      }
      if (item.adi == "BAKIM VAR MI") {
        bakimvarmi = item.deger;
      }
      if (item.adi == "ODULLU REKLAM ACIK MI") {
        odullureklamacikmi = item.deger;
      }
      if (item.adi == "ODULLU REKLAM ID") {
        odulluReklamId = item.deger;
      }
      if (item.adi == "TELEGRAM BUTON LINKI") {
        telegramlink = item.deger;
      }
      if (item.adi == "BANNER REKLAM ID") {
        bannerReklamId = item.deger;
      }
      if (item.adi == "BANNER REKLAM ACIK MI") {
        bannerReklamAcikMi = item.deger;
      }
      if (item.adi == "AI API KEY") {
        aiapikey = item.deger;
      }
      if (item.adi == "AI DUVAR KAĞIGI URETME LIMIT") {
        aiDuvarKagidiUretmeLimit = item.deger;
      }
      if (item.adi == "AI DUVAR KAĞIGI URETME MODEL") {
        aiDuvarKagidiUretmeModel = item.deger;
      }
    }
  }

  static bool String_To_Bool(String sonuc) {
    if (sonuc == "E") {
      return true;
    } else {
      return false;
    }
  }

  static int String_To_Int(String sonuc) {
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

    final base = resimsunucusu.trim();
    final effectiveBase = base.isEmpty ? _fallbackImageServerUrl : base;

    final cleanBase = effectiveBase.endsWith('/')
        ? effectiveBase.substring(0, effectiveBase.length - 1)
        : effectiveBase;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$cleanBase/$cleanPath';
  }
}
