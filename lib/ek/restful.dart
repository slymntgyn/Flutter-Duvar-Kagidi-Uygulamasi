import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:senseriduvarkagidi/ek/result.dart';

class Restful {
  static Future<ResultGet> getRequest(
      String link, BuildContext context, String fonksyion) async {
    ResultGet result = ResultGet();

    debugPrint('$link/api/$fonksyion');
    try {
      final http.Response response = await http.get(
        Uri.parse('$link/api/$fonksyion'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('API isteği zaman aşımına uğradı');
        },
      );

      debugPrint(
          '>> Api Fonksiyon : $link/api/$fonksyion : ${response.statusCode}');
      debugPrint('>> Api Response : ${response.body}');
      if (response.statusCode == 200) {
        result.sonuc = response.body.toString();
        return result;
      } else {
        result.hataMesaji = response.body;
        result.hata = true;
        return result;
      }
    } catch (error) {
      debugPrint('hata : $error');
      result.hata = true;
      if (error is TimeoutException) {
        result.hataMesaji = 'API isteği zaman aşımına uğradı';
      } else {
        result.hataMesaji = error.toString();
      }
      return result;
    }
  }

  static Future<ResultGet> postRequest(
      String link, BuildContext context, String fonksyion, String body) async {
    ResultGet result = ResultGet();
    try {
      final http.Response response = await http
          .post(Uri.parse('$link/api/$fonksyion'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8'
              },
              body: body)
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('API isteği zaman aşımına uğradı');
        },
      );
      debugPrint('>> Api Fonksiyon : $fonksyion : ${response.statusCode}');
      debugPrint('>> Api Response : ${response.body}');
      if (response.statusCode == 200) {
        result.sonuc = response.body.toString();
        return result;
      } else {
        result.hataMesaji = response.body;
        result.hata = true;
        return result;
      }
    } catch (error) {
      result.hata = true;
      if (error is TimeoutException) {
        result.hataMesaji = 'API isteği zaman aşımına uğradı';
      } else {
        result.hataMesaji = error.toString();
      }
      return result;
    }
  }
}

