import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Provider;
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Legacy imports (backward compatibility - mevcut ekranlar icin)
import 'package:senseriduvarkagidi/theme_provider.dart';

// New architecture imports
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/core/theme/app_theme.dart';
import 'package:senseriduvarkagidi/features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sistem UI stili
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Yalnizca dikey mod
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Reklam SDK
  MobileAds.instance.initialize();

  // SharedPreferences'i once olustur, ProviderScope'a override olarak ver.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      // Legacy ChangeNotifierProvider (eski ekranlar hala kullandigi icin)
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

/// Ana uygulama widget'i.
///
/// Riverpod [themeProvider] ile Material 3 temasini yonetir.
/// Eski ekranlar henuz legacy ThemeProvider'a bagli oldugu icin
/// her iki sistem de paralel calisir. Yeni ekranlar Riverpod'dan,
/// eski ekranlar Provider'dan temalaniyor.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod tema modu
    final themeMode = ref.watch(themeProvider);
    final themeData = AppTheme.fromMode(themeMode);

    // Legacy tema (eski ekranlarin bozulmamasini saglar)
    final legacyTheme = Provider.of<ThemeProvider>(context).themeData;

    // Yeni Material 3 temasini legacy temanin ustune merge et.
    // Boylece eski ekranlar bile yeni renk paletini alir.
    final mergedTheme = themeData.copyWith(
      // Legacy ekranlarin kullandigi primaryColor'i koru
      primaryColor: legacyTheme.primaryColor,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '4K-HD Duvar Kagitlari',
      theme: mergedTheme,
      darkTheme: AppTheme.dark(),
      themeMode: _mapToFlutterThemeMode(themeMode),
      home: const SplashScreen(),
    );
  }

  /// Kendi AppThemeMode enum'unu Flutter ThemeMode'a donusturur.
  ThemeMode _mapToFlutterThemeMode(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
        AppThemeMode.amoled => ThemeMode.dark,
      };
}
