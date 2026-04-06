import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';

class ImageList {
  int id = 0;
  String yol = "";
  String kategori = "";
  bool isPro = false;

  ImageList.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int? ?? 0;
    // API'de 'yol' klasor yolu, 'resiM_ADI' dosya adidir.
    final rawPath = (json['yol'] ?? '').toString().trim();
    final rawFileName = (json['resiM_ADI'] ?? '').toString().trim();
    if (rawPath.isNotEmpty && rawFileName.isNotEmpty) {
      final cleanPath = rawPath.endsWith('/')
          ? rawPath.substring(0, rawPath.length - 1)
          : rawPath;
      final cleanFileName =
          rawFileName.startsWith('/') ? rawFileName.substring(1) : rawFileName;
      yol = '$cleanPath/$cleanFileName';
    } else if (rawFileName.isNotEmpty) {
      yol = rawFileName;
    } else {
      yol = rawPath;
    }
    kategori = json['kategori'] as String? ?? '';
    isPro = _parseBool(json['iS_PRO']);
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == '1' ||
          normalized == 'true' ||
          normalized == 'evet' ||
          normalized == 'yes';
    }
    return false;
  }

  ImageList(this.id, this.yol, this.kategori, {this.isPro = false});
  static Future<List<ImageList>?> GetResimler(BuildContext context) async {
    try {
      Result_Get result =
          await Restful.Get_Request(ApiConstants.baseUrl, context, "resim");

      if (!context.mounted) {
        return null;
      }

      if (result.hata) {
        Yardimci.AlertDialogError(
            context, "Hata Oluştu", "Lütfen daha sonra tekrar deneyins");
      } else {
        if (result.sonuc != "") {
          var jsonlist = jsonDecode(result.sonuc.toString()) as List;
          List<ImageList> list = List<ImageList>.empty(growable: true);
          for (var e in jsonlist) {
            list.add(ImageList.fromJson(e));
          }
          Genel.Resimler = List<ImageList>.from(list);

          debugPrint('object${Genel.Resimler}');

          return list;
        }
      }
    } catch (error) {
      if (!context.mounted) {
        return null;
      }
      Yardimci.AlertDialogError(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyiniz");
      return null;
    }
    return null;
  }

  static Future<String?> FavorilereEkle(
      BuildContext context, int ResimId) async {
    try {
      Result_Get result = await Restful.Post_Request(ApiConstants.baseUrl,
          context, "kullanici/${Genel.CihazId}/favori/$ResimId", "");

      if (!context.mounted) {
        return "Hata";
      }

      debugPrint('$result');

      if (result.hata) {
        return "Hata : ${result.hataMesaji}";
      } else {
        return result.sonuc.toString();
      }
    } catch (error) {
      if (!context.mounted) {
        return "Hata";
      }
      Yardimci.AlertDialogError(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyiniz");
      return "Hata";
    }
  }
}
