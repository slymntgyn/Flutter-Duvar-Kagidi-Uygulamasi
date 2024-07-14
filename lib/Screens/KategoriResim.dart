import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senseriduvarkagidi/Screens/ImageDetay.dart';
import 'package:senseriduvarkagidi/Screens/Sayfalar.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/ek/widgets.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quickalert/quickalert.dart';
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

class KategoriResim extends StatefulWidget {
  const KategoriResim({
    Key? key,
  }) : super(key: key);

  @override
  State<KategoriResim> createState() => _KategoriResimState();
}

class _KategoriResimState extends State<KategoriResim> {
  dynamic selected;
  var heart = false;
  int index = 0;
  PageController controller = PageController();
  bool islem = false;
  Offset _tapPosition = Offset.zero;

  List<Widget> list_resimler = List<Widget>.empty(growable: true);
  List<Widget> no_resimler = List<Widget>.empty(growable: true);
  Color renk = Colors.white;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NoImage();
    Yukle();

    /*if(listResim.length==0){
      /*Genel.Resimler.shuffle();*/
      Siradaki(Random().nextInt(Genel.Resimler.length-1));
      Siradaki(Random().nextInt(Genel.Resimler.length-1));
    }*/
    /*Siradaki(0);
    Siradaki(1);*/
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, //to make floating action button notch transparent
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //to avoid the floating action button overlapping behavior,
      // when a soft keyboard is displayed
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Yardimci.Sayfa_Gecisi(context, Sayfalar());
          },
        ),
        title: Text(Genel.Kategoriler[int.parse(Genel.SecilenKategori)].kategori
            .toString()),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
            child: Stack(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: list_resimler.length > 0
                    ? GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(4.0),
                        mainAxisSpacing: 6.0,
                        crossAxisSpacing: 6.0,
                        children: list_resimler.toList())
                    : Center(
                        child: Text(
                        "Bu kategoride henüz duvar kağıdı yok.Çok Yakında...",
                        style: TextStyle(
                            color:
                                Genel.darkbutton ? Colors.white : Colors.black,
                            fontSize: 15),
                      )),
              ),
            ),
            islem == false ? Text("") : Widgets.Progress()
          ],
        )),
      )),
    );
  }

  void Yukle() {
    for (var i in Genel.Resimler) {
      setState(() {
        List<String> kategoriler = i.kategori.split(';');

        if (kategoriler.contains(Genel
            .Kategoriler[int.parse(Genel.SecilenKategori)].id
            .toString())) {
          list_resimler.add(Stack(
            children: [
              GestureDetector(
                child: Container(
                  child: Image.network(
                    fit: BoxFit.cover,
                    ayarlar.resimsunucusu + i.yol,
                    width: Genel.genislik,
                    height: Genel.yukseklik,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                onTap: () {
                  print("i.id1" + i.id.toString());

                  Genel.SecilenResimler = ImageList(i.id, i.yol, i.kategori);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImageDetay()),
                    /*MaterialPageRoute(
                         builder: (context) => ImageDetay(i.yol, i.id))*/
                  );
                },
                onTapDown: (details) => _getTapPosition(details),
                onLongPress: () {
                  print("Resime uzun basıldı tıklandı id : " +
                      i.id.toString() +
                      "Url :" +
                      i.yol);
                  _showContextMenu(context, i.yol, i.id);
                },
              )
            ],
          ));
        }
      });
    }
    print("list_resimler" + list_resimler.length.toString());
  }

  void NoImage() {
    for (var i in Genel.Resimler) {
      setState(() {
        no_resimler.add(Stack(
          children: [
            Center(
              child: Text(
                  "Herhangi bir resim  bulunamadı.Daha sonra Tekrar kontrol ediniz"),
            )
          ],
        ));
      });
    }
  }

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    });
  }

  void _showContextMenu(BuildContext context, String ImageUrl, int Id) async {
    final RenderObject? overlay =
        Overlay.of(context)?.context.findRenderObject();

    final result = await showMenu(
        context: context,

        // Show the context menu at the tap location
        position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),
        // set a list of choices for the context menu
        items: [
          Yardimci.favori_resimler_Kontrol(Id)
              ? const PopupMenuItem(
                  value: 'Favorilerden Çıkar',
                  child: Text('Favorilerden Çıkar'),
                )
              : const PopupMenuItem(
                  value: 'Favorilere Ekle',
                  child: Text('Favorilere Ekle'),
                ),
          const PopupMenuItem(
            value: 'Duvar Kağıdı Yap',
            child: Text('Duvar Kağıdı Yap'),
          ),
          const PopupMenuItem(
            value: 'İndir',
            child: Text('İndir'),
          ),
        ]);

    // Implement the logic for each choice here
    switch (result) {
      case 'Favorilerden Çıkar':
        FavorilereEkle(Id);

        break;
      case 'Favorilere Ekle':
        FavorilereEkle(Id);

        break;
      case 'Duvar Kağıdı Yap':
        QuickAlert.show(
          context: context,
          type: QuickAlertType.confirm,
          title: "Uyarı",
          text: "Seçilen görsel duvar kağıdı yapılacak onaylıyor musunuz?",
          confirmBtnText: 'Evet',
          cancelBtnText: 'Hayır',
          onConfirmBtnTap: () {
            if (ayarlar.odullureklamacikmi == "1") {
              if (Genel.reklam == null) {
                setWallpaper(ayarlar.resimsunucusu + ImageUrl, Id);
                KategoriList.ReklamYukle(context);
              } else {
                Genel.reklam?.show(onUserEarnedReward:
                    (AdWithoutView ad, RewardItem rewardItem) {
                  Navigator.of(context, rootNavigator: true).pop('dialog');


                  setWallpaper(ayarlar.resimsunucusu + ImageUrl, Id);
                  KategoriList.ReklamYukle(context);
                });
              }
            } else {
              setWallpaper(ayarlar.resimsunucusu + ImageUrl, Id);
            }
          },
        );

        break;
      case 'İndir':
        if (ayarlar.odullureklamacikmi == "1") {
          if (Genel.reklam == null) {
            Download(ayarlar.resimsunucusu + ImageUrl, Id);
            KategoriList.ReklamYukle(context);
          } else {
            Genel.reklam?.show(
                onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
              Navigator.of(context, rootNavigator: true).pop('dialog');

              Download(ayarlar.resimsunucusu + ImageUrl, Id);
              KategoriList.ReklamYukle(context);
            });
          }
        } else {
          Download(ayarlar.resimsunucusu + ImageUrl, Id);
        }

        break;
    }
  }

/*
  ImageDetay(String ImageUri, int Id) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Hero(
            tag: ayarlar.resimsunucusu + ImageUri,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: kIsWeb
                  ? Image.network(ayarlar.resimsunucusu + ImageUri,
                  fit: BoxFit.cover)
                  : CachedNetworkImage(
                imageUrl: ayarlar.resimsunucusu + ImageUri,
                placeholder: (context, url) => Container(
                  color: Color(0xfff5f8fd),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment(.8, -.8),
            child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
                icon: Icon(Icons.close)),
          ),
          Align(
              alignment: Alignment(0, .8),
              child: Container(
                margin: EdgeInsets.all(30),
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 33, 33, 33),
                    border: Border.all(
                        color: Colors.white10, // Set border color
                        width: 3.0), // Set border width
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
                          setWallpaper(ayarlar.resimsunucusu + ImageUri, Id);
                        },
                        color: Colors.white,
                        icon: Icon(Icons.wallpaper)),
                    IconButton(
                        onPressed: () {
                          Download(ayarlar.resimsunucusu + ImageUri, Id);
                        },
                        focusColor: Colors.white10,
                        color: Colors.white,
                        icon: Icon(Icons.download)),
                    IconButton(
                        onPressed: () {
                          print("Favorilere alınan index-->>>>>>" +
                              index.toString());
                          FavorilereEkle(Id);
                          setState(() {
                            if (Yardimci.favori_resimler_Kontrol(Id))
                              renk = Colors.red;
                            else
                              renk = Colors.white;
                            print("renk favoriler" + renk.toString());
                            //GetCardWidget(ImageUrl,Id);
                          });
                        },
                        focusColor: Colors.white10,
                        color: renk,
                        icon: Icon(Icons.favorite))
                  ],
                ),
              )),
        ],
      ),
    );
  }
*/
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
