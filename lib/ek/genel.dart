import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class Genel{
  // Tum legacy HTTP cagrilari ApiConstants.baseUrl uzerinden tek kaynaktan beslenir.
  static String get web_api_link => ApiConstants.baseUrl;

  static Color renk_kirmizi=Colors.white;

  static String UrlImage="";
  static int loginBackgroundIndex=0;
  static String SecilenKategori="";
  static int UrlImageId=0;
  static String CihazId="";
  static Color FavoriButonRengi=Colors.white;




  static double genislik=0;
  static double yukseklik=0;
  static bool darkbutton=true;

   static RewardedAd? reklam;
    static String adUnitId="";



  static List<String> yetkiler=List<String>.empty(growable: true);
  static List<ImageList> Resimler=List<ImageList>.empty(growable: true);
  static ImageList SecilenResimler=ImageList(UrlImageId,UrlImage,SecilenKategori);
  static List<KategoriList> Kategoriler=List<KategoriList>.empty(growable: true);
  static List<String> favoriresimler=List<String>.empty(growable: true);
  static List<String> tekresminkategorileri=List<String>.empty(growable: true);


  static List<Widget> resimwidget=List<Widget>.empty(growable: true);
  static List<Widget> favoriresimwidget=List<Widget>.empty(growable: true);


    static  List<String>bgList=[
      "assets/images/bg1.jpeg",
      "assets/images/bg2.jpeg",
      "assets/images/bg3.jpeg",
      "assets/images/bg4.webp",
      "assets/images/bg5.jpeg",
      "assets/images/bg6.jpeg",
      "assets/images/bg7.jpg",
      "assets/images/bg8.jpeg",
    ];
//static String mail_adresi="ssh.burotime@gmail.com";
//static String mail_sifre="burotime**2020";

}
