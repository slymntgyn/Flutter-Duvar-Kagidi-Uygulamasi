import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:senseriduvarkagidi/ek/result.dart';

class Restful {

  static Future<Result_Get> Get_Request(String link,BuildContext context,String fonksyion) async {
    Result_Get result=new Result_Get();


    print(link+ '/api/' + fonksyion);
    try {
      final http.Response response = await http.get(
        Uri.parse(link+ '/api/' + fonksyion),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

      print(">> Api Fonksiyon : "+link+ '/api/' + fonksyion+" : "+response.statusCode.toString());
      print(">> Api Response : "+response.body);
      if (response.statusCode == 200) {
        result.sonuc=response.body.toString();
        return result;
      }
      else {
        result.hataMesaji = response.body;
        result.hata=true;
        return result;
      }
    }
    catch (error) {
      print("hata : "+error.toString());
      result.hata=true;
      result.hataMesaji=error.toString();
      return result;
    }
  }





  static Future<Result_Get> Post_Request(String link,BuildContext context,String fonksyion, String body) async {
    Result_Get result=new Result_Get();
    try {
      final http.Response response = await http.post(
          Uri.parse(link + '/api/' + fonksyion),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: body
      );
      print(">> Api Fonksiyon : "+fonksyion+" : "+response.statusCode.toString());
      print(">> Api Response : "+response.body);
      if (response.statusCode == 200) {
        result.sonuc=response.body.toString();
        return result;
      }
      else {
        result.hataMesaji = response.body;
        result.hata=true;
        return result;
      }
    }
    catch (error) {
      result.hata=true;
      result.hataMesaji=error.toString();
      return result;
    }
  }

}