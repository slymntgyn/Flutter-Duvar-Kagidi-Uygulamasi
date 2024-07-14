import 'package:senseriduvarkagidi/model/Ayarlar.dart';

class ayarlar{

  static String resimsunucusu="";
  static String bakimvarmi="";
  static String odullureklamacikmi="";

  static void Ayarlari_Yukle(List<Ayarlar> list){
    if(list==null)
      return;

    if(list.length==0)
      return;

    for (var item in list) {
      if (item.adi == "RESIM SUNUCUSU")
        resimsunucusu =item.deger;
      if (item.adi == "BAKIM VAR MI")
        bakimvarmi =item.deger;
      if (item.adi == "ODULLU REKLAM ACIK MI")
        odullureklamacikmi =item.deger;

    }

  }


  static bool String_To_Bool(String sonuc){
    if(sonuc=="E")
      return true;
    else
      return false;
  }

  static int String_To_Int(String sonuc){
    try{
      return int.parse(sonuc);
    }catch(error){
      return 0;
    }
  }



}