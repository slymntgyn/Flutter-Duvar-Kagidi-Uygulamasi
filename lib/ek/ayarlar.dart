import 'package:senseriduvarkagidi/model/Ayarlar.dart';

class ayarlar{

  static String resimsunucusu="";
  static String bakimvarmi="";
  static String odullureklamacikmi="";
  static String odulluReklamId="";
  static String bannerReklamId="";
  static String bannerReklamAcikMi="";
  static String telegramlink="";
  static String aiapikey="";
  static String aiDuvarKagidiUretmeLimit="";
  static String aiDuvarKagidiUretmeModel="";

  static void Ayarlari_Yukle(List<Ayarlar> list){
    if(list.isEmpty) {
      return;
    }

    for (var item in list) {
      if (item.adi == "RESIM SUNUCUSU") {
        resimsunucusu =item.deger;
      }
      if (item.adi == "BAKIM VAR MI") {
        bakimvarmi =item.deger;
      }
      if (item.adi == "ODULLU REKLAM ACIK MI") {
        odullureklamacikmi =item.deger;
      }
      if (item.adi == "ODULLU REKLAM ID") {
        odulluReklamId =item.deger;
      }
      if (item.adi == "TELEGRAM BUTON LINKI") {
        telegramlink =item.deger;
      }
      if (item.adi == "BANNER REKLAM ID") {
        bannerReklamId =item.deger;
      }
      if (item.adi == "BANNER REKLAM ACIK MI") {
        bannerReklamAcikMi =item.deger;
      }
      if (item.adi == "AI API KEY") {
        aiapikey =item.deger;
      }
      if (item.adi == "AI DUVAR KAĞIGI URETME LIMIT") {
        aiDuvarKagidiUretmeLimit =item.deger;
      }
      if (item.adi == "AI DUVAR KAĞIGI URETME MODEL") {
        aiDuvarKagidiUretmeModel =item.deger;
      }
    }

  }


  static bool String_To_Bool(String sonuc){
    if(sonuc=="E") {
      return true;
    } else {
      return false;
    }
  }

  static int String_To_Int(String sonuc){
    try{
      return int.parse(sonuc);
    }catch(error){
      return 0;
    }
  }



}