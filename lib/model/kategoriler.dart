import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/restful.dart';
import 'package:senseriduvarkagidi/ek/result.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';

class KategoriList {
  int id = 0;
  String kategori = "";
  String categoryImage = "";

  KategoriList.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int? ?? 0;
    kategori = json['kategori'] as String? ?? '';
    categoryImage = json['categoryImage'] as String? ?? '';
  }

  static Future<List<KategoriList>?> getCategories(
      BuildContext context) async {
    try {
      ResultGet result =
          await Restful.getRequest(ApiConstants.baseUrl, context, "kategori");

      if (!context.mounted) {
        return null;
      }

      if (result.hata) {
        Yardimci.showErrorDialog(
            context, "Hata Oluştu", "Lütfen daha sonra tekrar deneyin");
      } else {
        if (result.sonuc != "") {
          var jsonlist = jsonDecode(result.sonuc.toString()) as List;
          List<KategoriList> list = List<KategoriList>.empty(growable: true);
          for (var json in jsonlist) {
            debugPrint('Kategori raw JSON: $json');
            list.add(KategoriList.fromJson(json));
          }
          Genel.categories = List<KategoriList>.from(list);

          debugPrint('object${Genel.images}');

          return list;
        }
      }
    } catch (error) {
      if (!context.mounted) {
        return null;
      }
      Yardimci.showErrorDialog(
          context, "Hata Oluştu", "Lütfen Daha Sonra Tekrar Deneyiniz");
      return null;
    }
    return null;
  }

  static Future<void> loadRewardedAd(BuildContext context) async {
    RewardedAd.load(
        adUnitId: Genel.adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.

            Genel.rewardedAd = ad;
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }
}

