import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';


class Ayarlar{
  String adi="";
  String deger="";

  Ayarlar.fromJson(Map<String, dynamic> json) {
    adi=json['adi'] as String;
    deger=json['deger'] as String;

    adi=adi==null?"":adi;
    deger=deger==null?"":deger;
  }
  static Future<List<Ayarlar>?> Ayarlari_Getir(BuildContext context) async {
    try {

      Result_Get result = await Restful.Get_Request(Genel.web_api_link,context, "DuvarKagidi/GetAyarlar");
      if(result.hata) {
      }else {
        if(result.sonuc!="") {
          var jsonlist = jsonDecode(result.sonuc) as List;
          List<Ayarlar> list = new List<Ayarlar>.empty(growable: true);
          jsonlist.forEach((e) {
            list.add(Ayarlar.fromJson(e));
          });
          return list;
        }
      }
    }
    catch(error){
      Yardimci.AlertDialogError(
          context,
          "Hata Oluştu",
          "Lütfen Daha Sonra Tekrar Deneyin");
    }
    return null;
  }
}