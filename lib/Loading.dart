import 'dart:math';
import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/Screens/Sayfalar.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/theme_provider.dart';
import 'package:provider/provider.dart';
import 'Screens/Anasayfa.dart';

class Loading extends StatefulWidget {
  @override
  Loading_State createState() => Loading_State();
}

class Loading_State extends State<Loading> {
  TextEditingController kullaniciAdiController = new TextEditingController();
  TextEditingController sifreController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    Setup();


  }

  Future<void> Setup() async {
    String darkmode = await Yardimci.Veri_Getir_String("darkmode");

    if(darkmode==""){
      darkmode="false";
    }
    Genel.darkbutton=bool.parse(darkmode) ;
    Color a=Theme.of(context).primaryColorDark;

    if(a==Color(0xff1976d2))
    {
      if(Genel.darkbutton)
      {
        Provider.of<ThemeProvider>(context,
            listen: false)
            .toggleTheme();
      }
    }

    List<Ayarlar>? list = await Ayarlar.Ayarlari_Getir(context);
    if (list != null) {
      ayarlar.Ayarlari_Yukle(list);
    }
    print("ayarlar.bakimvarmi"+ayarlar.bakimvarmi);
    if(ayarlar.bakimvarmi=="1"){
      Yardimci.AlertDialogUyari(context, "Bakım Çalışması", "Sistemde bakım çalışması vardır lütfen daha sonra tekrar deneyiniz.");
    }
    else{

      await  Yardimci.Cihaz_Bilgi_Getir();



      await Kullanici.Kullanici_Getir(context);
      await ImageList.GetResimler(context);
      await KategoriList.GetKategoriler(context);
      print("Genel.Kategoriler[0].kategori"+Genel.Kategoriler[0].kategorI_RESMI);
      KategoriList.ReklamYukle(context);


      Yardimci.Sayfa_Gecisi(context, Sayfalar());
    }


  }

  Widget build(BuildContext context) {
    Genel.genislik = MediaQuery.of(context).size.width;
    Genel.yukseklik = MediaQuery.of(context).size.height;

    return Scaffold(
      //resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child:Column(
                children: [
                  Container(

                    margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                    child: Image.asset(Genel.darkbutton?"assets/images/4K-HDWHITE.png":"assets/images/4K-HDBLACK.png",

                        width: Genel.genislik / 3 * 2)
                   // Text("4K-HD\n DUVAR KAĞITLARI",style: TextStyle(color: Colors.white)),

                  ),
                  Expanded(
                      flex: 1,child:
                  LoadingAnimationWidget.waveDots(color: Genel.darkbutton?Colors.white:Colors.black, size: 100) ),

                ],
              ),
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

}
