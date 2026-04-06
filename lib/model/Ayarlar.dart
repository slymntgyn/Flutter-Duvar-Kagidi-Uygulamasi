import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';

class Ayarlar {
  String adi = "";
  String deger = "";

  Ayarlar.fromJson(Map<String, dynamic> json) {
    adi = json['adi'] as String? ?? "";
    deger = json['deger'] as String? ?? "";
  }
  static Future<List<Ayarlar>?> Ayarlari_Getir(BuildContext context) async {
    try {
      Result_Get result =
          await Restful.Get_Request(ApiConstants.baseUrl, context, "ayar");
      if (!context.mounted) {
        return null;
      }
      if (result.hata) {
      } else {
        if (result.sonuc != "") {
          var jsonlist = jsonDecode(result.sonuc) as List;
          List<Ayarlar> list = List<Ayarlar>.empty(growable: true);
          for (var e in jsonlist) {
            list.add(Ayarlar.fromJson(e));
          }
          return list;
        }
      }
    } catch (error) {
      if (!context.mounted) {
        return null;
      }
      Yardimci.AlertDialogError(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyin");
    }
    return null;
  }
}
