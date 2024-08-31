import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class Genel{
  //Canlı
    static String web_api_link="https://api.suleymanturan.com";

  static Color renk_kirmizi=Colors.white;

  static String UrlImage="";
  static String SecilenKategori="";
  static int UrlImageId=0;
  static String CihazId="";
  static Color FavoriButonRengi=Colors.white;




  static double genislik=0;
  static double yukseklik=0;
  static bool darkbutton=true;

   static RewardedAd? reklam;
    static final adUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';



  static List<String> yetkiler=new List<String>.empty(growable: true);
  static List<ImageList> Resimler=new List<ImageList>.empty(growable: true);
  static ImageList SecilenResimler=new ImageList(UrlImageId,UrlImage,SecilenKategori);
  static List<KategoriList> Kategoriler=new List<KategoriList>.empty(growable: true);
  static List<String> favoriresimler=new List<String>.empty(growable: true);
  static List<String> tekresminkategorileri=new List<String>.empty(growable: true);


  static List<Widget> resimwidget=new List<Widget>.empty(growable: true);
  static List<Widget> favoriresimwidget=new List<Widget>.empty(growable: true);


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

    static final List<List<String>> _dropdownItems = [
      ['Erkek', 'Kadın', 'Diğer']
    ];
//static String mail_adresi="ssh.burotime@gmail.com";
//static String mail_sifre="burotime**2020";

}
