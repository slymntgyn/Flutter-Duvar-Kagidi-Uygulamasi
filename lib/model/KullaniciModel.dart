import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';


class Kullanici{
  String yetkiler="";
  String favorI_RESIMLER="";

  Kullanici.fromJson(Map<String, dynamic> json) {
    yetkiler = json['yetkiler'] ;
    favorI_RESIMLER = json['favorI_RESIMLER'] ;

    yetkiler=(yetkiler==null?"":yetkiler);
    favorI_RESIMLER=(favorI_RESIMLER==null?"":favorI_RESIMLER);
  }

  static Future<Kullanici?> Kullanici_Getir(BuildContext context) async {
    try {


      print(Genel.CihazId);
      Genel.CihazId=Genel.CihazId.replaceAll('/', '');
      Genel.CihazId=Genel.CihazId.replaceAll('<', '');
      Result_Get result = await Restful.Get_Request(Genel.web_api_link,context, "DuvarKagidi/kullaniciGetir/"+ Genel.CihazId.replaceAll('/', '')!);
      if (result.hata){
        print('>>>> result.hata'+result.hata.toString());
        Yardimci.AlertDialogError(context, "Hata Oluştu","Lütfen daha sonra tekrar deneyiniz");
      }

      else {
        if(result.sonuc!="") {
          var jsonlist = jsonDecode(result.sonuc.toString());
          Kullanici item=(Kullanici.fromJson(jsonlist));
          Yardimci.Yetkileri_Yukle(item.yetkiler);
          Yardimci.favori_resimleri_Yukle(item.favorI_RESIMLER);

          print(Genel.yetkiler);  

          return item;
        }
      }
    }
    catch (error) {
      print("Hata"+ error.toString());
      Yardimci.AlertDialogError(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyiniz");
    }
    return null;
  }
  static Future<String?> IslemLog(BuildContext context,String CihazId,String Islem,int Resim) async {
    try {

      Result_Get result = await Restful.Get_Request(Genel.web_api_link,context, "DuvarKagidi/IslemLog/"+Genel.CihazId+"/"+Islem.toString()+"/"+Resim.toString());

      print(result);

      if (result.hata)
        return "Hata ";
      else {

        return result.sonuc.toString();
      }
    }
    catch(error){

      return "Hata";
    }
  }
}