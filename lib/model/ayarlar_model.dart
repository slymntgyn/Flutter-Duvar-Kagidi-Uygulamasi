import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';

class Ayarlar {
  String adi = "";
  String deger = "";

  Ayarlar.fromJson(Map<String, dynamic> json) {
    adi = json['adi'] as String? ?? "";
    deger = json['deger'] as String? ?? "";
  }

  static const String _userFriendlySettingsError =
      'Ayarlar su anda yuklenemiyor. Lutfen internetini kontrol edip tekrar dene.';

  static Future<List<Ayarlar>?> getSettings(BuildContext context) async {
    try {
      ResultGet result =
          await Restful.getRequest(ApiConstants.baseUrl, context, "ayar");
      if (!context.mounted) {
        return null;
      }
      if (result.hata) {
        throw Exception(result.hataMesaji.isNotEmpty
            ? result.hataMesaji
            : _userFriendlySettingsError);
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
      throw Exception(_userFriendlySettingsError);
    }
    return null;
  }
}
