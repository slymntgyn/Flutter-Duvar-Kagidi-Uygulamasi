import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';


class KategoriList{
  int id=0;
  String kategori="";
  String kategorI_RESMI="";

  KategoriList.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int? ?? 0;
    kategori = json['kategori'] as String? ?? '';
    kategorI_RESMI = json['kategorI_RESMI'] as String? ?? '';
  }

  static Future<List<KategoriList>?> GetKategoriler(BuildContext context) async {
    try {




      Result_Get result = await Restful.Get_Request(Genel.web_api_link,context, "kategori");


      if (result.hata) {
        Yardimci.AlertDialogError(context, "Hata Oluştu", "Lütfen daha sonra tekrar deneyin");
      } else {
        if(result.sonuc!="") {
          var jsonlist = jsonDecode(result.sonuc.toString()) as List;
          List<KategoriList> list = List<KategoriList>.empty(growable: true);
          for (var e in jsonlist) {
            list.add(KategoriList.fromJson(e));

          }
          Genel.Kategoriler=list;


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
  static Future<void> ReklamYukle(BuildContext context) async {
    RewardedAd.load(
        adUnitId: Genel.adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.

            Genel.reklam = ad;
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }
}