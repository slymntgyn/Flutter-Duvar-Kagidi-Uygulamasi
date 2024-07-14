import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:line_icons/line_icons.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
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
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:url_launcher/url_launcher.dart';


class ReelScreen extends StatelessWidget {
  const ReelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView.builder(
        itemCount: Genel.Resimler.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) => ReelItem(index: index),
      ),
    );
  }
}
getcard(int index){

  return Stack(
    children: [
      Text("Rastgele",
          style: TextStyle(
              color: Colors.white.withOpacity(0.98),
              fontSize: 25,
              fontWeight: FontWeight.w800)),
      Container(
        width: double.infinity,
        height: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.black54,
          image: DecorationImage(
              image: NetworkImage(
                ayarlar.resimsunucusu+ Genel.Resimler[index].yol, //ContentImg
              ),
              fit: BoxFit.cover),
        ),
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.0),
                    ])),
            height: 80.0,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(""
                  ),

                ],
              ),
            ),
          ),

        ],
      )
    ],
  );
}


class ReelItem extends StatelessWidget {
  const ReelItem({
    required this.index,
    Key? key,
  }) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    dynamic selected;
    var heart = false;
    PageController controller = PageController();
    print("this.index"+this.index.toString());

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: StylishBottomBar(
        backgroundColor: Color.fromARGB(255, 33, 33, 33),
        option: AnimatedBarOptions(
          // iconSize: 32,
          barAnimation: BarAnimation.fade,
          iconStyle: IconStyle.animated,
          // opacity: 0.3,
        ),
        items: [

          BottomBarItem(
            icon: const Icon(Icons.image),
            selectedIcon: const Icon(Icons.image),
            selectedColor: Colors.cyan,
            // unSelectedColor: Colors.purple,
            // backgroundColor: Colors.orange,
            title: const Text('Rastgele'),
          ),
          BottomBarItem(
              icon: const Icon(
                Icons.favorite,
              ),
              selectedIcon: const Icon(
                Icons.favorite,
              ),
              backgroundColor: Colors.red,
              selectedColor: Colors.red,
              title: const Text('Favoriler')),
        ],
        currentIndex: selected ?? 0,
        onTap: (index) {
          controller.jumpToPage(index);

        },
      ),

      body: SafeArea(
        child: PageView(
          controller: controller,
          children:  [
            /* Center(child: Text('Kategoriler')),*/
            getcard(index),
            Container(child: Text(""),
            )
          ],
        ),
      ),
    );
  }
}
