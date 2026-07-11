/// Uygulama genelinde kullanilan sabitler.
class AppConstants {
  AppConstants._();

  static const String appName = '4K-HD Duvar Kağıtları';

  // AI Generation
  static const int defaultAiDailyLimit = 3; // Pro varsayilan gunluk limit
  static const int freeAiDailyLimit = 1; // Ucretsiz kullanici gunluk deneme hakki
  static const int maxGenerationHistory = 10;

  // Retry
  static const int maxRetryAttempts = 3;
  static const List<Duration> retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  // Image
  static const int thumbnailCacheWidth = 400;
  static const int thumbnailCacheHeight = 600;
  static const int fullImageCacheWidth = 800;
  static const int fullImageCacheHeight = 1200;

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyDeviceId = 'device_unique_id';
  static const String keyDarkMode = 'darkmode';
  static const String keyLastAiGenDate = 'last_wallpaper_date';
  static const String keyAiGenCount = 'daily_wallpaper_count';

  // Splash backgrounds
  static const List<String> splashBackgrounds = [
    'assets/images/bg1.jpeg',
    'assets/images/bg2.jpeg',
    'assets/images/bg3.jpeg',
    'assets/images/bg4.webp',
    'assets/images/bg5.jpeg',
    'assets/images/bg6.jpeg',
    'assets/images/bg7.jpg',
    'assets/images/bg8.jpeg',
  ];

  // AI Styles
  static const List<String> aiStyles = [
    'Gerçekçi',
    'Anime',
    'Soyut',
    'Fantastik',
    'Siberpunk',
    'Doğa',
  ];
}

