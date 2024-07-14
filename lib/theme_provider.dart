
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier{
  ThemeData _themeData = ThemeData.light();

  ThemeData get themeData =>_themeData;

  set themeData(ThemeData themeData){
    _themeData=themeData;
    notifyListeners();
  }

  void  toggleTheme(){
    print(_themeData);
    if(_themeData==ThemeData.light()){
      print("Tema Koyu Yapıldı");
      themeData=ThemeData.dark();
    }
    else
    {
      print("Tema Açık Yapıldı");
      themeData=ThemeData.light();
    }
  }

}