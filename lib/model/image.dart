
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';


class ImageList{
  int id=0;
  String yol="";
  String kategori="";
  bool isPro=false;

  ImageList.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int? ?? 0;
    // API 'yol' = dizin URL, 'resiM_ADI' = dosya adi. Ikisini birlestir.
    yol = json['resiM_ADI'] as String? ?? '';
    kategori = json['kategori'] as String? ?? '';
    isPro = json['iS_PRO'] as bool? ?? false;
  }

  ImageList(this.id, this.yol, this.kategori, {this.isPro = false});
  static Future<List<ImageList>?> GetResimler(BuildContext context) async {
    try {



      Result_Get result = await Restful.Get_Request(Genel.web_api_link,context, "resim");


      if (result.hata) {
        Yardimci.AlertDialogError(context, "Hata Oluştu", "Lütfen daha sonra tekrar deneyins");
      } else {
        if(result.sonuc!="") {
          var jsonlist = jsonDecode(result.sonuc.toString()) as List;
          List<ImageList> list = List<ImageList>.empty(growable: true);
          for (var e in jsonlist) {
            list.add(ImageList.fromJson(e));

          }
          Genel.Resimler=list;


          print("object${Genel.Resimler}");


          return list;
        }
      }
    }
    catch(error){
      Yardimci.AlertDialogError(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyiniz");
      return null;
    }
    return null;
  }
  static Future<String?> FavorilereEkle(BuildContext context,int ResimId) async {
    try {

      Result_Get result = await Restful.Post_Request(Genel.web_api_link,context, "kullanici/${Genel.CihazId}/favori/$ResimId", "");

      print(result);

      if (result.hata) {
        return "Hata : ${result.hataMesaji}";
      } else {

        return result.sonuc.toString();
      }
    }
    catch(error){
      Yardimci.AlertDialogError(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyiniz");
      return "Hata";
    }
  }
}