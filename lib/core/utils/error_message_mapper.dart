/// Teknik hata metinlerini kullanici dostu metinlere cevirir.
String mapErrorMessage(Object error) {
  final String raw = error.toString().trim().toLowerCase();

  if (raw.contains('socketexception') ||
      raw.contains('connectionerror') ||
      raw.contains('failed host lookup') ||
      raw.contains('connection refused') ||
      raw.contains('hostlookup') ||
      raw.contains('internet bağlantısı yok') ||
      raw.contains('internet baglantisi yok') ||
      raw.contains('network')) {
    return 'Internet baglantisi yok. Baglantini kontrol edip tekrar dene.';
  }

  if (raw.contains('timeout') ||
      raw.contains('receive timeout') ||
      raw.contains('connection timeout') ||
      raw.contains('zaman asimina')) {
    return 'Baglanti zaman asimina ugradi. Internetini kontrol edip tekrar dene.';
  }

  if (raw.contains('429') ||
      raw.contains('rate limit') ||
      raw.contains('too many requests')) {
    return 'Cok fazla istek gonderildi. Lutfen kisa bir sure sonra tekrar dene.';
  }

  if (raw.contains('401') ||
      raw.contains('403') ||
      raw.contains('unauthorized') ||
      raw.contains('forbidden')) {
    return 'Bu islem icin yetkin bulunmuyor. Lutfen daha sonra tekrar dene.';
  }

  if (raw.contains('500') ||
      raw.contains('502') ||
      raw.contains('503') ||
      raw.contains('server')) {
    return 'Sunucu tarafinda bir sorun olustu. Lutfen daha sonra tekrar dene.';
  }

  if (raw.contains('maintenance') ||
      raw.contains('bakim') ||
      raw.contains('service unavailable')) {
    return 'Sunucu su anda bakimda. Lutfen daha sonra tekrar dene.';
  }

  if (raw.contains('permission') || raw.contains('izin')) {
    return 'Gerekli izin verilmedi. Ayarlardan izinleri kontrol et.';
  }

  return 'Bir sorun olustu. Lutfen tekrar dene.';
}
