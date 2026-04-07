import 'dart:convert';
import 'dart:math';
import 'package:quickalert/quickalert.dart';
import 'package:flutter/material.dart';
import 'genel.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart'; // For sha256

class Yardimci {
  static Future<void> showExitDialog(
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
  static Future<void> showWarningDialog(
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
    final List<int> bytes = utf8.encode(password);

    // SHA-256 algoritması ile hash'le
    final Digest digest = sha256.convert(bytes);

    // Hash'i hexadecimal string olarak döndür
    return digest.toString();
  }
  static Future<void> showErrorDialog(BuildContext context,String baslik,String icerik){

    return  QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: baslik,
      text: icerik,
        confirmBtnText: "Tamam"
    );

  }
  static Future<void> showSuccessDialog(BuildContext context,String baslik,String icerik){

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
  static int showSetWallpaperDialog(BuildContext context,String baslik,String icerik){
int selection = 0;
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        text: "Lütfen duvar kağıdı yapmak istediğiniz ekranı seçiniz.",
      widget: Column(
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
          TextButton.icon(
            style: TextButton.styleFrom(
                foregroundColor: Colors.black45,
                textStyle: const TextStyle(fontSize: 20)),
            icon: const Icon(Icons.lock),
            onPressed: () {
              selection = 1;
            },
            label: const Text('Kilit Ekranı'),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
                foregroundColor: Colors.black45,
                textStyle: const TextStyle(fontSize: 20)),
            icon: const Icon(Icons.home),
            onPressed: () {
              selection = 2;
            },
            label: const Text('Ana Ekran'),
          ),TextButton.icon(
            style: TextButton.styleFrom(
                foregroundColor: Colors.black45,
                textStyle: const TextStyle(fontSize: 20)),
            icon: const Icon(Icons.phone_android),
            onPressed: () {
              selection = 3;
            },
            label: const Text('Her ikiside'),
          ),

        ],
      )


    );
return selection;
  }
  static Future<String> getDeviceInfo() async {
    String deviceId = "";

    try {
      // Kaydedilmiş ID kontrol et
      final prefs = await SharedPreferences.getInstance();
      deviceId = prefs.getString('device_unique_id') ?? '';

      if (deviceId.isEmpty) {
        // Yeni ID oluştur
        String platform = Platform.isAndroid ? "AND" : "IOS";
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String random = Random().nextInt(999999).toString().padLeft(6, '0');

        deviceId = "$platform-$timestamp-$random";

        // Kaydet ki bir daha oluşturmasın
        await prefs.setString('device_unique_id', deviceId);
        debugPrint("Yeni cihaz ID oluşturuldu: $deviceId");
      } else {
        debugPrint("Mevcut cihaz ID kullanılıyor: $deviceId");
      }

    } catch (e) {
      debugPrint("Cihaz ID hatası: $e");
      // En basit fallback
      deviceId = "DEV-${DateTime.now().millisecondsSinceEpoch}";
    }

    // SHA256 ile hash'le
    var bytes = utf8.encode(deviceId);
    var digest = sha256.convert(bytes);
    String finalId = digest.toString();

    Genel.deviceId = "CIHAZ : ${finalId.trim()}";
    debugPrint(Genel.deviceId);

    return finalId;
  }

  static void navigateToPage(BuildContext context, Widget newPage) {
    /*Navigator.push(
        context, MaterialPageRoute(builder: (BuildContext context) => newPage));*/

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => newPage),
        (e) => false);
  }

  static String formatDate(String tarih) {
    String yeniTarih = tarih.replaceAll('.', '');
    try {
      String tarih2 = yeniTarih.split(' ')[0];
      String saat = yeniTarih.split(' ')[1];
      return "${tarih2.split('-')[2]}-${tarih2.split('-')[1]}-${tarih2.split('-')[0]} $saat";
    } catch (error) {
      return tarih;
    }
  }

  static String formatDateShort(String tarih) {
    String yeniTarih = tarih.replaceAll('.', '');
    try {
      String tarih2 = yeniTarih.split(' ')[0];
      return "${tarih2.split('-')[2]}/${tarih2.split('-')[1]}/${tarih2.split('-')[0]}";
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
  static bool hasPermission(String yetki){
    return Genel.yetkiler.contains(yetki);
    }

  static void loadPermissions(String yetkilerStr){
    try{
      final List<String> yetkiler = yetkilerStr.split(';');
      for (final String item in yetkiler){
        if (item.isNotEmpty) {
          Genel.yetkiler.add(item);
        }

      }
    }catch(error){
      debugPrint(error.toString());
    }

  }
  static void loadFavoriteImages(String favoriimages){
    try{
      final List<String> favoriteImages = favoriimages.split(';');
      for (final String item in favoriteImages){
        if (item.isNotEmpty) {
          Genel.favoriteImages.add(item);
        }
      }
    }catch(error){
      debugPrint(error.toString());
    }

  }
  static void toggleFavoriteImage(String favoriResim){
    try{
        if (Genel.favoriteImages.contains(favoriResim)) {
          Genel.favoriteImages.remove(favoriResim);
        } else {
          Genel.favoriteImages.add(favoriResim);
        }
    }catch(error){
      debugPrint(error.toString());
    }

  }
  static Future<void> saveString(String name, String value) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString(name, value);
  }

  static Future<String> getString(String name) async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getString(name) ?? "");
  }
  static bool isFavoriteImage(int yetki){
    return Genel.favoriteImages.contains(yetki.toString());
    }

  static double bytesToMb(int bayt) {
    if (bayt > 0) {
      return (bayt / (1000 * 1000));
    } else {
      return double.parse(bayt.toString());
    }
  }


}


