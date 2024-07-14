import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/Screens/ImageDetay.dart';
import 'package:senseriduvarkagidi/Screens/KategoriResim.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/theme.dart';
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
import 'package:vibration/vibration.dart';
import 'package:senseriduvarkagidi/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Sayfalar extends StatefulWidget {
  const Sayfalar({
    Key? key,
  }) : super(key: key);

  @override
  State<Sayfalar> createState() => _SayfalarState();
}

class _SayfalarState extends State<Sayfalar> {
  final FlareControls flareControls = FlareControls();
  dynamic selected;
  var heart = false;
  int indexvalue = 0;
  PageController controller = PageController();
  bool islem = false;
  TextEditingController kullaniciAdiController = new TextEditingController();
  TextEditingController sifreController = new TextEditingController();

  List<ImageList> FavoriResimler = new List<ImageList>.empty(growable: true);
  List<Widget> no_Resimler = new List<Widget>.empty(growable: true);

  PageController pageController = PageController();
  List<ImageList> list = Genel.Resimler;
  Offset _tapPosition = Offset.zero;
  List<Widget> listResim = new List<Widget>.empty(growable: true);
  List<Widget> listKategori = new List<Widget>.empty(growable: true);
  List<Widget> listFavoriResim = new List<Widget>.empty(growable: true);
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

    GetKategoriListWidget();
    //FavoriResimListDoldur();
    print("FavoriResimler" + FavoriResimler.toString());
    Genel.Resimler.shuffle();
    Yukle();
    NoImage();
  }
/*
  void loadAd() {
    RewardedAd.load(
        adUnitId: adUnitId,
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
  }*/

  void Yukle() {
    if (Genel.Resimler.length >= 5) {
      for (int i = 0; i < 5; i++) {
        setState(() {
          listResim.add((Stack(
            children: [
              Container(
                child: Image.network(
                    fit: BoxFit.cover,
                    ayarlar.resimsunucusu +
                        Genel.Resimler[listResim.length].yol,
                    width: Genel.genislik,
                    height: Genel.yukseklik),
              )
            ],
          )));
        });
      }
    } else {
      for (int i = 0; i < Genel.Resimler.length; i++) {
        setState(() {
          listResim.add((Stack(
            children: [
              Container(
                child: Image.network(
                    fit: BoxFit.cover,
                    ayarlar.resimsunucusu +
                        Genel.Resimler[listResim.length].yol,
                    width: Genel.genislik,
                    height: Genel.yukseklik),
              )
            ],
          )));
        });
      }
    }
  }

  void GetKategoriListWidget() {
    if (listKategori.length == 0) {
      for (int i = 0; i < Genel.Kategoriler.length; i++) {
        setState(() {
          listKategori.add(GestureDetector(
              onTap: () {
                print("Genel.Kategoriler[i].id.toString();" +
                    Genel.Kategoriler[i].id.toString());
                Genel.SecilenKategori = i.toString();
                Yardimci.Sayfa_Gecisi(context, KategoriResim());
              },
              child: Column(
                children: [
                  Container(
                      width: Genel.genislik,
                      height: Genel.yukseklik / 4.2,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        child: Image.network(
                            fit: BoxFit.cover,
                            ayarlar.resimsunucusu +
                                Genel.Kategoriler[i].kategorI_RESMI,
                            width: Genel.genislik, loadingBuilder:
                                (BuildContext context, Widget child,
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
                        }, height: Genel.yukseklik),
                      )).scrollTransition(
                    (context, widget, event) => widget
                        .blur(
                          switch (event.phase) {
                            ScrollPhase.identity => 0,
                            ScrollPhase.topLeading => 10,
                            ScrollPhase.bottomTrailing => 20,
                          },
                        )
                        .scale(
                          switch (event.phase) {
                            ScrollPhase.identity => 1,
                            ScrollPhase.topLeading => 0.5,
                            ScrollPhase.bottomTrailing => 0.5,
                          },
                        ),
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Text(
                        Genel.Kategoriler[i].kategori,
                        style: TextStyle(
                            color:
                                Genel.darkbutton ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22.0),
                      )),
                ],
              )));
        });
      }
    }
  }
  /*yourFunction(BuildContext context) {
    pageController.nextPage(duration: Duration(seconds: 1), curve: Curves.bounceIn);
    pageController.nextPage(duration: Duration(seconds: 1), curve: Curves.bounceIn);
  }*/

  FavoriResimListDoldur() {
    FavoriResimler.clear();
    for (var i in Genel.Resimler) {
      if (double.parse(i.id.toString()) > 0) {
        setState(() {
          Yardimci.favori_resimler_Kontrol(i.id) == true
              ? FavoriResimler.add(ImageList(i.id, i.yol, i.kategori))
              : "";
        });
      }
    }
    print("teest" + FavoriResimler.length.toString());
    var j = 0;
    if (FavoriResimler.length != 0) {
      listFavoriResim.clear();
      FavoriResimler.shuffle();
      for (var i in FavoriResimler) {
        setState(() {
          GetFavoriCardWidget(FavoriResimler[j].yol, FavoriResimler[j].id);
        });

        j++;
      }

      /* SiradakiFavoriler(0);
      SiradakiFavoriler(FavoriResimler.length-1);*/
    }
  }

  GetSetWallpaperType(String ImageUrl, int id) {
    QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        text: "Lütfen duvar kağıdı yapmak istediğiniz ekranı seçiniz.",
        widget: Column(
          children: [
            Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
            TextButton.icon(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.black45,
                  textStyle: const TextStyle(fontSize: 20)),
              icon: const Icon(Icons.lock),
              onPressed: () {
                print("1");
              },
              label: const Text('Kilit Ekranı'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.black45,
                  textStyle: const TextStyle(fontSize: 20)),
              icon: const Icon(Icons.home),
              onPressed: () {
                print("2");
              },
              label: const Text('Ana Ekran'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.black45,
                  textStyle: const TextStyle(fontSize: 20)),
              icon: const Icon(Icons.phone_android),
              onPressed: () {
                print("3");
              },
              label: const Text('Her ikiside'),
            ),
          ],
        ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, //to make floating action button notch transparent
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      bottomNavigationBar: StylishBottomBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        option: BubbleBarOptions(
          inkEffect: true,
          barStyle: BubbleBarStyle.vertical,
          bubbleFillStyle: BubbleFillStyle.outlined,
          opacity: 0.3,
        ),
        items: [
          BottomBarItem(
            icon: const Icon(
              Icons.category,
              color: Colors.white60,
            ),
            selectedIcon: Icon(Icons.category, color: Colors.white),
            // selectedColor: Colors.teal,
            backgroundColor: Colors.teal,
            title: Text('Kategoriler',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 15, color: Colors.white)),
          ),
          BottomBarItem(
            icon: const Icon(
              Icons.house_outlined,
              color: Colors.white60,
            ),
            selectedIcon: Icon(Icons.house_rounded, color: Colors.white),
            // selectedColor: Colors.teal,
            backgroundColor: Colors.teal,
            title: Text('Rastgele',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 15, color: Colors.white)),
          ),
          BottomBarItem(
            icon: const Icon(
              Icons.star_border_rounded,
              color: Colors.white60,
            ),
            selectedIcon: Icon(Icons.star_rounded, color: Colors.white),

            selectedColor: Colors.red,
            // unSelectedColor: Colors.purple,
            // backgroundColor: Colors.orange,
            title: Text(
              textAlign: TextAlign.center,
              'Favorilerim',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 15, color: Colors.white),
            ),
          ),
        ],
        hasNotch: true,
        currentIndex: selected ?? 0,
        onTap: (index) {
          indexvalue = 0;

          Vibration.vibrate(duration: 100);
          if (index == 2) {
            FavoriResimListDoldur();
          } else if (index == 1) {
            setState(() {
              if (Yardimci.favori_resimler_Kontrol(
                  Genel.Resimler[indexvalue].id))
                renk = Colors.red;
              else
                renk = Colors.white;
            });
            print("Value Index" + indexvalue.toString());
          }
          controller.jumpToPage(index);
          setState(() {
            selected = index;
          });
        },
      ),

      /*floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            heart = !heart;
            if (heart) {
              index = 2;
              FavoriResimListDoldur();
              selected=index;
              controller.jumpToPage(index);
            } else {
              index = 1;
              selected=index;
              controller.jumpToPage(index);
            }
          });
        },

        backgroundColor: Color.fromARGB(255, 33, 33, 33),
        child: Icon(
          heart ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          color: Colors.red,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,*/

      body: SafeArea(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            new Column(
              children: <Widget>[
                new Row(
                  children: [
                    new Expanded(
                      child: new Align(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Genel.darkbutton
                                  ? Icon(Icons.dark_mode)
                                  : Icon(Icons.light_mode),
                              title: Text("Hoş Geldiniz"),
                              trailing: Switch(
                                value: Genel.darkbutton,
                                onChanged: (value) {
                                  Provider.of<ThemeProvider>(context,
                                          listen: false)
                                      .toggleTheme();
                                  Genel.darkbutton = !Genel.darkbutton;
                                  Yardimci.Veri_Kaydet_String(
                                      "darkmode", Genel.darkbutton.toString());
                                },
                              ),
                            )
                          ],
                        ),
                        alignment: Alignment(0.9, 0.8),
                      ),
                    ),
                  ],
                ),
                new Expanded(
                  child: new ListView(
                    children: listKategori,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onDoubleTap: () {
                FavorilereEkle(Genel.Resimler[indexvalue].id);
                setState(() {
                  if (Yardimci.favori_resimler_Kontrol(
                      Genel.Resimler[indexvalue].id)) {
                    renk = Colors.red;
                    flareControls.play("like");
                  } else
                    renk = Colors.white;
                  //GetCardWidget(ImageUrl,Id);
                });
              },
              child: Center(
                  child: Stack(
                children: [
                  Container(
                    child: PageView(
                      scrollDirection: Axis.vertical,
                      controller: pageController,
                      children: listResim,
                      onPageChanged: (i) {
                        setState(() {
                          indexvalue = i;
                        });
                        print(">> Açılan index : " +
                            indexvalue.toString() +
                            " yol : " +
                            Genel.Resimler[indexvalue].yol);

                        setState(() {
                          if (Yardimci.favori_resimler_Kontrol(
                              Genel.Resimler[indexvalue].id))
                            renk = Colors.red;
                          else
                            renk = Colors.white;
                        });

                        if (i == listResim.length - 2) Yukle();
                      },
                    ),
                  ),
                  Align(
                      alignment: Alignment(1.2, 1),
                      child: Container(
                        height: 230,
                        margin: EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () {
                                  print(">> Favori index : " +
                                      indexvalue.toString() +
                                      " yol : " +
                                      Genel.Resimler[indexvalue].yol);
                                  FavorilereEkle(Genel.Resimler[indexvalue].id);
                                  setState(() {
                                    if (Yardimci.favori_resimler_Kontrol(
                                        Genel.Resimler[indexvalue].id)) {
                                      renk = Colors.red;
                                      flareControls.play("like");
                                    } else
                                      renk = Colors.white;
                                    //GetCardWidget(ImageUrl,Id);
                                  });
                                },
                                focusColor: Colors.white10,
                                color: renk,
                                icon: Icon(Icons.favorite_sharp)),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text("Beğen",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            IconButton(
                                onPressed: () {
                                  //   GetSetWallpaperType(Genel.Resimler[indexvalue].yol,
                                  //        Genel.Resimler[indexvalue].id)

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
                                              Genel.Resimler[indexvalue].yol,
                                              Genel.Resimler[indexvalue].id);
                                          KategoriList.ReklamYukle(context);
                                        } else {
                                          Genel.reklam?.show(onUserEarnedReward:
                                              (AdWithoutView ad,
                                                  RewardItem rewardItem) {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop('dialog');
                                            ad.dispose();

                                            setWallpaper(
                                                Genel.Resimler[indexvalue].yol,
                                                Genel.Resimler[indexvalue].id);
                                            KategoriList.ReklamYukle(context);
                                          });
                                        }
                                      } else {
                                        setWallpaper(
                                            Genel.Resimler[indexvalue].yol,
                                            Genel.Resimler[indexvalue].id);
                                      }
                                    },
                                  );
                                },
                                color: Colors.white,
                                icon: Icon(Icons.wallpaper)),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text(
                                "Duvar Kağıdı",
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  if (ayarlar.odullureklamacikmi == "1") {
                                    if (Genel.reklam == null) {
                                      Download(Genel.Resimler[indexvalue].yol,
                                          Genel.Resimler[indexvalue].id);
                                      KategoriList.ReklamYukle(context);
                                    } else {
                                      Genel.reklam?.show(onUserEarnedReward:
                                          (AdWithoutView ad,
                                              RewardItem rewardItem) {
                                        Download(Genel.Resimler[indexvalue].yol,
                                            Genel.Resimler[indexvalue].id);
                                        KategoriList.ReklamYukle(context);
                                      });
                                    }
                                  } else {
                                    Download(Genel.Resimler[indexvalue].yol,
                                        Genel.Resimler[indexvalue].id);
                                  }
                                },
                                focusColor: Colors.white10,
                                color: Colors.white,
                                icon: Icon(Icons.download)),
                            Text("İndir",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      )),
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
                  islem == false ? Text("") : Widgets.Progress()
                ],
              )),
            ),
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                  child: Stack(
                children: [
                  Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: FavoriResimler.length.toString() != "0"
                            ? GridView.count(
                                crossAxisCount: 2,
                                childAspectRatio: 0.6,
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                padding: const EdgeInsets.all(4.0),
                                mainAxisSpacing: 6.0,
                                crossAxisSpacing: 6.0,
                                children: listFavoriResim.toList())
                            : Center(
                                child: Column(
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(
                                        0, Genel.yukseklik / 2.5, 0, 0),
                                    child: Icon(
                                      size: 150,
                                      Icons.favorite_border_outlined,
                                      color: Genel.darkbutton
                                          ? Colors.white
                                          : Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    "Henüz favorlerinize resim almadınız",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontSize: 15,
                                            color: Genel.darkbutton
                                                ? Colors.white
                                                : Colors.black),
                                  ),
                                ],
                              )),
                      )),
                  islem == false ? Text("") : Widgets.Progress()
                ],
              )),
            )
          ],
        ),
      ),
    );
  }

  void NoImage() {
    for (var i in Genel.Resimler) {
      setState(() {
        no_Resimler.add(Stack(
          children: [
            Center(
              child: Text("Henüz favorilerinize resim almadınız."),
            )
          ],
        ));
      });
    }
  }

  void GetCardWidget(String ImageUrl, int Id) {
    print(">> Id : " + Id.toString());
    print(">> ImageUrl : " + ImageUrl.toString());

    listResim.add(Stack(
      children: [
        Container(
          child: Image.network(
            fit: BoxFit.cover,
            ayarlar.resimsunucusu + ImageUrl,
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
        )
      ],
    ));
  }

  void GetFavoriCardWidget(String ImageUrl, int Id) {
    print(">> Id : " + Id.toString());
    print("listFavoriResim" + listFavoriResim.toString());
    setState(() {
      listFavoriResim.add(Stack(
        children: [
          GestureDetector(
            child: Container(
              child: Image.network(
                fit: BoxFit.cover,
                ayarlar.resimsunucusu + ImageUrl,
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
              String kategori = "";
              for (var i in Genel.Resimler) {
                if (i.id == Id) {
                  kategori = i.kategori;
                }
              }
              print("Seçilen resm" + ImageUrl);
              Genel.SecilenResimler = ImageList(Id, ImageUrl, kategori);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageDetay()),
                /*MaterialPageRoute(
                      builder: (context) => ImageDetay(ImageUrl, Id))
              */
              );
            },
            onTapDown: (details) => _getTapPosition(details),
            onLongPress: () {
              print("Resime uzun basıldı tıklandı id : " +
                  Id.toString() +
                  "Url :" +
                  ImageUrl);
              _showContextMenu(context, ImageUrl, Id);
            },
          )
        ],
      ));
    });
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
          PopupMenuItem(
            value: 'Favorilerden Çıkar',
            child: Text(
              'Favorilerden Çıkar',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: Genel.darkbutton ? Colors.white : Colors.black),
            ),
          ),
          PopupMenuItem(
            value: 'Duvar Kağıdı Yap',
            child: Text(
              'Duvar Kağıdı Yap',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: Genel.darkbutton ? Colors.white : Colors.black),
            ),
          ),
          PopupMenuItem(
            value: 'İndir',
            child: Text(
              'İndir',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  color: Genel.darkbutton ? Colors.white : Colors.black),
            ),
          ),
        ]);

    // Implement the logic for each choice here
    switch (result) {
      case 'Favorilerden Çıkar':
        FavorilereEkle(Id);
        FavoriResimListDoldur();
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
                setWallpaper(ImageUrl, Id);
                KategoriList.ReklamYukle(context);
              } else {
                Genel.reklam?.show(onUserEarnedReward:
                    (AdWithoutView ad, RewardItem rewardItem) {
                  Navigator.of(context, rootNavigator: true).pop('dialog');

                  setWallpaper(ImageUrl, Id);
                  KategoriList.ReklamYukle(context);
                });
              }
            } else {
              setWallpaper(ImageUrl, Id);
            }
          },
        );
        break;
      case 'İndir':
        if (ayarlar.odullureklamacikmi == "1") {
        if (Genel.reklam == null) {
          Download(ImageUrl, Id);
          FavoriResimListDoldur();
          KategoriList.ReklamYukle(context);
        } else {
          Genel.reklam?.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            Download(ImageUrl, Id);
            FavoriResimListDoldur();
            KategoriList.ReklamYukle(context);
          });
        }}
        else
        {
          Download(ImageUrl, Id);
        }

        break;
    }
  }

  Cikis() {
    Yardimci.AlertDialogExit(
        context as BuildContext, "Çıkış", "Çıkmak istediğinize emin misiniz?");
  }

  Future<void> Download(String UrlImage, int Id) async {
    try {
      setState(() {
        islem = true;
      });
      UrlImage = ayarlar.resimsunucusu + UrlImage;
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
      String url = ayarlar.resimsunucusu + ImageUrl;
      int location = WallpaperManager
          .LOCK_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
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
      FavoriResimListDoldur();
      print("listFavoriResim" + listFavoriResim.length.toString());
    } on PlatformException {
      Yardimci.AlertDialogError(
          context as BuildContext, "Hata oluştu", "İşlem gerçekleştirilemedi");
    }
  }
}
