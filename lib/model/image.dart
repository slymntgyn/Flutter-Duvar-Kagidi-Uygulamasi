
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';


class ImageList{
  int id=0;
  String yol="";
  String kategori="";

  ImageList.fromJson(Map<String, dynamic> json) {
    id=json['id'] as int;
    yol=json['yol'] as String;
    kategori=json['kategori'] as String;


    id=id==null?0:id;
    yol=yol==null?"":yol;
    kategori=kategori==null?"":kategori;
  }

  ImageList(this.id, this.yol,this.kategori);
  static Future<List<ImageList>?> GetResimler(BuildContext context) async {
    try {



      Result_Get result = await Restful.Get_Request(Genel.web_api_link,context, "DuvarKagidi/ResimGetir");


      if (result.hata)
        Yardimci.AlertDialogError(context, "Hata Oluştu", "Lütfen daha sonra tekrar deneyins");
      else {
        if(result.sonuc!="") {
          var jsonlist = jsonDecode(result.sonuc.toString()) as List;
          List<ImageList> list = new List<ImageList>.empty(growable: true);
          jsonlist.forEach((e) {
            list.add(ImageList.fromJson(e));

          });
          Genel.Resimler=list as List<ImageList>;


          print("object"+Genel.Resimler.toString());


          return list;
        }
      }
    }
    catch(error){
      Yardimci.AlertDialogError(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyiniz");
      return null;
    }
  }
  static Future<String?> FavorilereEkle(BuildContext context,int ResimId) async {
    try {

      Result_Get result = await Restful.Get_Request(Genel.web_api_link,context, "DuvarKagidi/FavorilerEkle/"+Genel.CihazId+"/"+ResimId.toString());

      print(result);

      if (result.hata)
        return "Hata : "+result.hataMesaji.toString();
      else {

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