import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senseriduvarkagidi/Screens/Sayfalar.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/ek/widgets.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/Screens/KategoriResim.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:flutter/services.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/widgets.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:quickalert/quickalert.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ImageDetay extends StatefulWidget {
  const ImageDetay({
    Key? key,
  }) : super(key: key);

  @override
  State<ImageDetay> createState() => _ImageDetayState();
}

class _ImageDetayState extends State<ImageDetay> {
  final FlareControls flareControls = FlareControls();
  bool islem = false;
  Color renk = Colors.white;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    KategoriList.ReklamYukle(context);
    print("i.id2" + Genel.SecilenResimler.id.toString());
    setState(() {
      if (Yardimci.favori_resimler_Kontrol(Genel.SecilenResimler.id))
        renk = Colors.red;
      else
        renk = Colors.white;
      print("renk favoriler" + renk.toString());
      //GetCardWidget(ImageUrl,Id);
    });
  }

  /*void loadAd() {
    RewardedAd.load(
        adUnitId: Genel.adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.

            _rewardedAd = ad;
          },

          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('RewardedAd failed to load: $error');
          },
        ));
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Hero(
              tag: ayarlar.resimsunucusu + Genel.SecilenResimler.yol,
              child: GestureDetector(
                  onDoubleTap: () {
                    FavorilereEkle(Genel.SecilenResimler.id);
                    setState(() {
                      if (Yardimci.favori_resimler_Kontrol(
                          Genel.SecilenResimler.id)) {
                        renk = Colors.red;
                        flareControls.play("like");
                      } else
                        renk = Colors.white;
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child:  Image.network(
                                ayarlar.resimsunucusu +
                                    Genel.SecilenResimler.yol,
                                fit: BoxFit.cover)
                            
                      ),
                      Container(
                        width: double.infinity,
                        height: Genel.yukseklik / 1.2,
                        child: Center(
                          child: SizedBox(
                            width: 120,
                            height: 120,
                            child: FlareActor(
                              'assets/images/like.flr',
                              controller: flareControls,
                              animation: 'idle',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))),
          Align(
            alignment: Alignment(.8, -.8),
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
                icon: Icon(Icons.close)),
          ),
          Opacity(
            child: Align(
                alignment: Alignment(0, .9),
                child: Container(
                  margin: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      border: Border.all(
                          color: Colors.white10, // Set border color
                          width: 1.0), // Set border width
                      borderRadius: BorderRadius.all(
                          Radius.circular(10.0)), // Set rounded corner radius
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 10,
                            color: Colors.black,
                            offset: Offset(1, 3))
                      ] // Make rounded corner of border
                      ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.confirm,
                              title: "Uyarı",
                              text:
                                  "Seçilen görsel duvar kağıdı yapılacak onaylıyor musunuz?",
                              confirmBtnText: 'Evet',
                              cancelBtnText: 'Hayır',
                              onConfirmBtnTap: () {
                                if (ayarlar.odullureklamacikmi == "1") {
                                  if (Genel.reklam == null) {
                                    setWallpaper(
                                        ayarlar.resimsunucusu +
                                            Genel.SecilenResimler.yol,
                                        Genel.SecilenResimler.id);
                                    KategoriList.ReklamYukle(context);
                                  } else {
                                    Genel.reklam?.show(onUserEarnedReward:
                                        (AdWithoutView ad,
                                            RewardItem rewardItem) {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');

                                      setWallpaper(
                                          ayarlar.resimsunucusu +
                                              Genel.SecilenResimler.yol,
                                          Genel.SecilenResimler.id);
                                      KategoriList.ReklamYukle(context);
                                    });
                                  }
                                } else {
                                  setWallpaper(
                                      ayarlar.resimsunucusu +
                                          Genel.SecilenResimler.yol,
                                      Genel.SecilenResimler.id);
                                }
                              },
                            );

                            //setWallpaper(ayarlar.resimsunucusu +  Genel.SecilenResimler.yol,  Genel.SecilenResimler.id);
                          },
                          color: Colors.white,
                          icon: Icon(Icons.wallpaper)),
                      IconButton(
                          onPressed: () {
                            if (ayarlar.odullureklamacikmi == "1") {
                              if (Genel.reklam == null) {
                                Download(
                                    ayarlar.resimsunucusu +
                                        Genel.SecilenResimler.yol,
                                    Genel.SecilenResimler.id);
                                KategoriList.ReklamYukle(context);
                              } else {
                                Genel.reklam?.show(onUserEarnedReward:
                                    (AdWithoutView ad, RewardItem rewardItem) {
                                  Download(
                                      ayarlar.resimsunucusu +
                                          Genel.SecilenResimler.yol,
                                      Genel.SecilenResimler.id);
                                  KategoriList.ReklamYukle(context);
                                });
                              }
                            } else {
                              Download(
                                  ayarlar.resimsunucusu +
                                      Genel.SecilenResimler.yol,
                                  Genel.SecilenResimler.id);
                            }
                          },
                          focusColor: Colors.white10,
                          color: Colors.white,
                          icon: Icon(Icons.download)),
                      IconButton(
                          onPressed: () {
                            FavorilereEkle(Genel.SecilenResimler.id);
                            setState(() {
                              if (Yardimci.favori_resimler_Kontrol(
                                  Genel.SecilenResimler.id)) {
                                renk = Colors.red;
                                flareControls.play("like");
                              } else
                                renk = Colors.white;
                              print("renk favoriler" + renk.toString());
                              //GetCardWidget(ImageUrl,Id);
                            });
                          },
                          focusColor: Colors.white10,
                          color: renk,
                          icon: Icon(Icons.favorite)),
                    ],
                  ),
                )),
            opacity: 0.8,
          ),
          islem == false ? Text("") : Widgets.Progress()
        ],
      ),
    );
  }

  Future<void> Download(String UrlImage, int Id) async {
    try {
      setState(() {
        islem = true;
      });
      UrlImage = UrlImage;
      print("UrlImage" + UrlImage.toString());
      DateTime now = new DateTime.now();
      DateTime date = new DateTime(
          now.year, now.month, now.day, now.hour, now.minute, now.second);
      var response = await Dio()
          .get(UrlImage, options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: date.toString());
      print("resul" + result.toString());

      if (result.toString().contains("true")) {
        Kullanici.IslemLog(context, Genel.CihazId, "Download", Id);
        Yardimci.AlertDialogBasarili(context as BuildContext, "Başarılı",
            "İşlem başarılı şekilde gerçekleşti");
      } else {
        Yardimci.AlertDialogError(context as BuildContext, "Hata oluştu",
            "İşlem gerçekleştirilemedi");
      }
      setState(() {
        islem = false;
      });
    } on PlatformException {
      setState(() {
        islem = false;
      });
      Yardimci.AlertDialogError(
          context as BuildContext, "Hata oluştu", "İşlem gerçekleştirilemedi");
    }
  }

  Future<void> setWallpaper(String ImageUrl, int id) async {
    try {
      setState(() {
        islem = true;
      });
      String url = ImageUrl;
      int location = WallpaperManager
          .BOTH_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(url);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
      print(result);
      if (result == true) {
        Kullanici.IslemLog(context, Genel.CihazId, "Duvar Kagidi Yapma", id);
        Yardimci.AlertDialogBasarili(context as BuildContext, "Başarılı",
            "İşlem başarılı şekilde gerçekleşti");
      } else {
        Yardimci.AlertDialogError(context as BuildContext, "Hata oluştu",
            "İşlem gerçekleştirilemedi");
      }

      setState(() {
        islem = false;
      });
    } on PlatformException {
      setState(() {
        islem = false;
      });
      Yardimci.AlertDialogError(
          context as BuildContext, "Hata oluştu", "İşlem gerçekleştirilemedi");
    }
  }

  Future<void> FavorilereEkle(int Id) async {
    try {
      ImageList.FavorilereEkle(context, Id);
      Yardimci.favori_resim_ekle(Id.toString());
    } on PlatformException {
      Yardimci.AlertDialogError(
          context as BuildContext, "Hata oluştu", "İşlem gerçekleştirilemedi");
    }
  }
}
