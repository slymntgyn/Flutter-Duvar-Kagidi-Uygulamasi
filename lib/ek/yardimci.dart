import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'genel.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:device_uuid/device_uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For utf8.encode
import 'package:crypto/crypto.dart'; // For sha256

class Yardimci {
  static Future<void> AlertDialogExit(
      BuildContext context, String baslik, String icerik) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: baslik,
      text: icerik,
      confirmBtnText: 'Evet',
      cancelBtnText: 'Hayır',
      confirmBtnColor: Colors.black87,
      onConfirmBtnTap: () {
        exit(0);
      },
    );
  }
  static Future<void> AlertDialogUyari(
      BuildContext context, String baslik, String icerik) {
    return QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: baslik,
      text: icerik,
      confirmBtnText: 'Tamam',
      confirmBtnColor: Colors.black87,
      onConfirmBtnTap: () {
        exit(0);
      },
    );
  }
  static String hashPassword(String password) {
    // Şifreyi UTF-8 formatında encode et
    var bytes = utf8.encode(password);

    // SHA-256 algoritması ile hash'le
    var digest = sha256.convert(bytes);

    // Hash'i hexadecimal string olarak döndür
    return digest.toString();
  }
  static Future<void> AlertDialogError(BuildContext context,String baslik,String icerik){

    return  QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: baslik,
      text: icerik,
        confirmBtnText: "Tamam"
    );

  }
  static Future<void> AlertDialogBasarili(BuildContext context,String baslik,String icerik){

    return  QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: baslik,
      text: icerik,
      confirmBtnText: "Tamam",
        onConfirmBtnTap: () {

      Navigator.of(context, rootNavigator: true)
          .pop('dialog');
        },
    );

  }
  static int AlertDialogSetWallpaper(BuildContext context,String baslik,String icerik){
var aa=0;
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
              aa=1;
            },
            label: const Text('Kilit Ekranı'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
                foregroundColor: Colors.black45,
                textStyle: const TextStyle(fontSize: 20)),
            icon: const Icon(Icons.home),
            onPressed: () {
              aa=2;
            },
            label: const Text('Ana Ekran'),
          ),TextButton.icon(
            style: TextButton.styleFrom(
                foregroundColor: Colors.black45,
                textStyle: const TextStyle(fontSize: 20)),
            icon: const Icon(Icons.phone_android),
            onPressed: () {
              aa=3;
            },
            label: const Text('Her ikiside'),
          ),

        ],
      )


    );
return aa;
  }
  static Future<String> Cihaz_Bilgi_Getir() async {
    String? deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.

      final uuid = DeviceUuid().getUUID();
      deviceId = await uuid;


    Genel.CihazId=deviceId!;
    Genel.CihazId="CIHAZ : "+Genel.CihazId!.trim();
    print(Genel.CihazId);
    return deviceId!;
  }
  static void Sayfa_Gecisi(BuildContext context, Widget newPage) {
    /*Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => newPage));*/

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => newPage),
        (e) => false);
  }

  static String Tarih_Formatla(String tarih) {
    if (tarih == null) return "";
    //2020-09-17 00:00:00. => //17-09-2020 00:00:00
    String yeniTarih = tarih.replaceAll('.', '');
    try {
      String tarih2 = yeniTarih.split(' ')[0];
      String saat = yeniTarih.split(' ')[1];
      return tarih2.split('-')[2] +
          "-" +
          tarih2.split('-')[1] +
          "-" +
          tarih2.split('-')[0] +
          " " +
          saat;
    } catch (error) {
      return tarih;
    }
  }

  static String Tarih_Formatla2(String tarih) {
    if (tarih == null) return "";
    //2020-09-17 00:00:00. => //17-09-2020 00:00:00
    String yeniTarih = tarih.replaceAll('.', '');
    try {
      String tarih2 = yeniTarih.split(' ')[0];
      String saat = yeniTarih.split(' ')[1];
      return tarih2.split('-')[2] +
          "/" +
          tarih2.split('-')[1] +
          "/" +
          tarih2.split('-')[0];
    } catch (error) {
      return tarih;
    }
  }

/*  static Future<String> Ip_Getir() async {
    try {
      var ipAddress = IpAddress(type: RequestType.json);

      dynamic data = await ipAddress.getIpAddress();

      return data;
    } catch (error) {
      return "";
    }
  }*/
  static bool Yetki_Kontrol(String yetki){
    if(Genel.yetkiler!=null){
      if(Genel.yetkiler.contains(yetki))
        return true;
      else
        return false;
    }else
      return false;
  }

  static Yetkileri_Yukle(String yetkiler_str){
    try{
      List<String> yetkiler=yetkiler_str.split(';');
      for(var item in yetkiler){
        if(item!="")
          Genel.yetkiler.add(item);

      }
    }catch(error){

    }

  }
  static favori_resimleri_Yukle(String favori_resimler){
    try{
      List<String> favoriresimler=favori_resimler.split(';');
      for(var item in favoriresimler){
        if(item!="")
          Genel.favoriresimler.add(item);
      }
    }catch(error){

    }

  }
  static favori_resim_ekle(String favori_resim){
    try{

        if(Genel.favoriresimler.contains(favori_resim))
          Genel.favoriresimler.remove(favori_resim);
        else
          Genel.favoriresimler.add(favori_resim);





    }catch(error){

    }

  }
  static Future<void> Veri_Kaydet_String(String name, String value) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(name, value);
  }

  static Future<String> Veri_Getir_String(String name) async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getString(name) ?? "");
  }
  static bool favori_resimler_Kontrol(int yetki){
    if(Genel.favoriresimler!=null){

      if(Genel.favoriresimler.contains(yetki.toString()))
        return true;
      else
        return false;
    }else
      return false;
  }

  static double Bayt_to_Mb(int bayt) {
    if (bayt > 0) {
      return (bayt / (1000 * 1000));
    } else
      return double.parse(bayt.toString());
  }


}
