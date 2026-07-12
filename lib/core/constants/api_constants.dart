/// API endpoint sabitleri.
/// Tum API URL'leri burada merkezi olarak tanimlanir.
class ApiConstants {
  ApiConstants._();

  /// Tum platformlarda tek API hostu kullanilir.
  static const String baseUrl = 'https://api.suleymanturan.com';

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
  static String getPremiumStatus(String deviceId) => '/api/premium/$deviceId';

  /// Premium aboneligi aktif eder.
  static String activatePremium(String deviceId) =>
      '/api/premium/$deviceId/activate';

  /// Gunluk AI uretim sayisini getirir.
  static String getAiUsage(String deviceId) =>
      '/api/premium/$deviceId/ai-usage';

  /// AI uretimini loglar ve gunluk sayaci arttirir.
  static String logAiGeneration(String deviceId) =>
      '/api/premium/$deviceId/ai-log';

  // ==================== NVIDIA AI (gorsel uretim) ====================

  /// NVIDIA NIM (build.nvidia.com) hosted gorsel uretim API kok adresi.
  static const String nvidiaBaseUrl = 'https://ai.api.nvidia.com/v1/genai';

  /// Varsayilan NVIDIA gorsel modeli.
  /// NOT: flux.1-schnell bazi hesaplarda yanit vermeyip asili kaliyor;
  /// flux.1-dev stabil calisiyor (bkz. nvidia_ai_service steps mantigi).
  static const String defaultNvidiaModel = 'black-forest-labs/flux.1-dev';

  /// Verilen model icin tam uretim endpoint'ini olusturur.
  /// Ornek: '$nvidiaBaseUrl/black-forest-labs/flux.1-schnell'
  static String nvidiaImageGeneration(String model) => '$nvidiaBaseUrl/$model';

  // ==================== Timeout'lar ====================

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration aiConnectTimeout = Duration(seconds: 30);
  static const Duration aiReceiveTimeout = Duration(seconds: 120);
}
