import 'dart:io';
import 'package:flutter/material.dart';
import 'package:senseriduvarkagidi/Loading.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/theme.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:senseriduvarkagidi/theme_provider.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(ChangeNotifierProvider(create: (context) => ThemeProvider(),
  child: const MyApp(),)

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '4K-HD Duvar Kağıtları',
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Loading(),
    );
  }
}


