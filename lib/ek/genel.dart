
import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class Genel{
  // Tum legacy HTTP cagrilari ApiConstants.baseUrl uzerinden tek kaynaktan beslenir.
  static String get webApiLink => ApiConstants.baseUrl;

  static Color redColor=Colors.white;

  static String imageUrl="";
  static int loginBackgroundIndex=0;
  static String selectedCategory="";
  static int imageUrlId=0;
  static String deviceId="";
  static Color favoriteButtonColor=Colors.white;




  static double width=0;
  static double height=0;
  static bool darkButton=true;

   static RewardedAd? rewardedAd;
    static String adUnitId="";



  static List<String> yetkiler=List<String>.empty(growable: true);
  static List<ImageList> images=List<ImageList>.empty(growable: true);
  static ImageList selectedImage=ImageList(imageUrlId,imageUrl,selectedCategory);
  static List<KategoriList> categories=List<KategoriList>.empty(growable: true);
  static List<String> favoriteImages=List<String>.empty(growable: true);
  static List<String> singleImageCategories=List<String>.empty(growable: true);


  static List<Widget> imageWidgets=List<Widget>.empty(growable: true);
  static List<Widget> favoriteImageWidgets=List<Widget>.empty(growable: true);


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


