/// API endpoint sabitleri.
/// Tum API URL'leri burada merkezi olarak tanimlanir.
class ApiConstants {
  ApiConstants._();

  /// Debug/Profile build → test.suleymanturan.com  (mevcut canlı, eski mimari)
  /// Release build      → api.suleymanturan.com    (yeni mimari, controller'lara bölünmüş)
  /// Manuel override    → flutter build apk --dart-define=API_BASE_URL=https://...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: bool.fromEnvironment('dart.vm.product')
        ? 'https://api.suleymanturan.com'   // Release (Google Play)
        : 'https://test.suleymanturan.com', // Debug / gelistirme
  );

  // ==================== Uygulama Endpointleri ====================

  /// Uygulama ayarlarini getirir.
  static const String getSettings = '/api/ayar';

  /// Tum duvar kagitlarini getirir.
  static const String getImages = '/api/resim';

  /// Aktif kategorileri getirir.
  static const String getCategories = '/api/kategori';

  /// Cihaz ID'ye gore kullanici getirir veya olusturur.
  static String getUser(String deviceId) => '/api/kullanici/$deviceId';

  /// Favorilere resim ekler / cikarir.
  static String toggleFavorite(String deviceId, int imageId) =>
      '/api/kullanici/$deviceId/favori/$imageId';


  /// Kullanici islem logu atar (duvar kagidi yapma, indirme vb).
  static String logAction(String deviceId, String action, int imageId) =>
      '/api/kullanici/$deviceId/islem/$action/$imageId';

  // ==================== Premium Endpointleri ====================

  /// Premium durumu ve AI kullanim bilgisini getirir.
  static String getPremiumStatus(String deviceId) =>
      '/api/premium/$deviceId';

  /// Premium aboneligi aktif eder.
  static String activatePremium(String deviceId) =>
      '/api/premium/$deviceId/activate';

  /// Gunluk AI uretim sayisini getirir.
  static String getAiUsage(String deviceId) =>
      '/api/premium/$deviceId/ai-usage';

  /// AI uretimini loglar ve gunluk sayaci arttirir.
  static String logAiGeneration(String deviceId) =>
      '/api/premium/$deviceId/ai-log';

  // ==================== Harici AI API'leri ====================

  /// OpenRouter API
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterChatCompletions =
      '$openRouterBaseUrl/chat/completions';

  /// OpenAI API
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiImageGeneration =
      '$openAiBaseUrl/images/generations';

  // ==================== Timeout'lar ====================

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration aiConnectTimeout = Duration(seconds: 30);
  static const Duration aiReceiveTimeout = Duration(seconds: 120);
}
