/// API endpoint sabitleri.
/// Tum API URL'leri burada merkezi olarak tanimlanir.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.suleymanturan.com';
  static const String _basePath = '/api/DuvarKagidi';

  // Endpoints
  static const String getSettings = '$_basePath/GetAyarlar';
  static const String getImages = '$_basePath/ResimGetir';
  static const String getCategories = '$_basePath/GetKategoriler';

  static String getUser(String deviceId) =>
      '$_basePath/kullaniciGetir/$deviceId';

  static String toggleFavorite(String deviceId, int imageId) =>
      '$_basePath/FavorilerEkle/$deviceId/$imageId';

  static String logAction(String deviceId, String action, int imageId) =>
      '$_basePath/IslemLog/$deviceId/$action/$imageId';

  // External APIs
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterChatCompletions =
      '$openRouterBaseUrl/chat/completions';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration aiConnectTimeout = Duration(seconds: 30);
  static const Duration aiReceiveTimeout = Duration(seconds: 120);
}
