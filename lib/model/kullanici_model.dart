import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';

class Kullanici {
  String yetkiler = "";
  String favoriteImagesRaw = "";

  Kullanici.fromJson(Map<String, dynamic> json) {
    yetkiler = json['yetkiler'] as String? ?? '';
    favoriteImagesRaw = json['favoriteImagesRaw'] as String? ?? '';
  }

  static Future<Kullanici?> getUser(BuildContext context) async {
    try {
      debugPrint(Genel.deviceId);
      Genel.deviceId = Genel.deviceId.replaceAll('/', '');
      Genel.deviceId = Genel.deviceId.replaceAll('<', '');
      ResultGet result = await Restful.getRequest(Genel.webApiLink, context,
          "kullanici/${Genel.deviceId.replaceAll('/', '')}");
      if (!context.mounted) {
        return null;
      }
      if (result.hata) {
        debugPrint('>>>> result.hata${result.hata}');
        Yardimci.showErrorDialog(
            context, "Hata Oluştu", "Lütfen daha sonra tekrar deneyiniz");
      } else {
        if (result.sonuc != "") {
          var jsonlist = jsonDecode(result.sonuc.toString());
          Kullanici item = (Kullanici.fromJson(jsonlist));
          Yardimci.loadPermissions(item.yetkiler);
          Yardimci.loadFavoriteImages(item.favoriteImagesRaw);

          debugPrint(Genel.yetkiler.toString());

          return item;
        }
      }
    } catch (error) {
      debugPrint("Hata$error");
      if (!context.mounted) {
        return null;
      }
      Yardimci.showErrorDialog(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyiniz");
    }
    return null;
  }

  static Future<String?> logAction(
      BuildContext context, String deviceId, String action, int imageId) async {
    try {
      ResultGet result = await Restful.getRequest(Genel.webApiLink, context,
          "kullanici/${Genel.deviceId}/islem/$action/$imageId");

      debugPrint(result.toString());

      if (result.hata) {
        return "Hata ";
      } else {
        return result.sonuc.toString();
      }
    } catch (error) {
      return "Hata";
    }
  }
}


