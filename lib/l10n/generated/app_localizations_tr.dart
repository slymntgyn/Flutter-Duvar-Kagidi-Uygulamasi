// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get navExplore => 'Keşfet';

  @override
  String get navCategories => 'Kategoriler';

  @override
  String get navFavorites => 'Favoriler';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get premiumSection => 'Premium';

  @override
  String get themeSection => 'Görsel Tema';

  @override
  String get aboutSection => 'Hakkında';

  @override
  String get themeLight => 'Açık Tema';

  @override
  String get themeDark => 'Koyu Tema';

  @override
  String get themeAmoled => 'AMOLED (Saf Siyah)';

  @override
  String themeActivated(String name) {
    return '$name aktif edildi';
  }

  @override
  String get appVersion => 'Uygulama Sürümü';

  @override
  String get proUserTitle => 'Pro Kullanıcısı';

  @override
  String get proUserSubtitle => 'Tüm özellikler aktif';

  @override
  String get freePlanTitle => 'Ücretsiz Plan';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return 'Günlük $remaining/$limit AI üretim hakkı';
  }

  @override
  String get upgradeToPro => 'Pro\'ya Yüksel';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle =>
      'Yapay zeka ile duvar kağıdı üretmenin kilidini aç';

  @override
  String get featureNvidiaTitle => 'NVIDIA AI ile Üretim';

  @override
  String get featureNvidiaDesc =>
      'Hayalindeki duvar kağıdını NVIDIA yapay zekasıyla saniyeler içinde oluştur';

  @override
  String get featureStylesTitle => 'Tüm Sanat Stilleri';

  @override
  String get featureStylesDesc =>
      '10+ stil açılır: gerçekçi, anime, siberpunk, fantastik ve daha fazlası';

  @override
  String get featureAdFreeTitle => 'Reklamsız Deneyim';

  @override
  String get featureAdFreeDesc =>
      'Banner ve tüm reklamlar kalkar, kesintisiz kullanırsın';

  @override
  String get featureApplyTitle => 'Tek Dokunuşla Uygula';

  @override
  String get featureApplyDesc =>
      'Ürettiğin görseli ana/kilit ekranına uygula, indir veya paylaş';

  @override
  String get aiLockedNotice =>
      'AI duvar kağıdı üretimi şu an kilitli. Pro ile hemen aç.';

  @override
  String get monthlyPro => 'Aylık Pro';

  @override
  String get monthlyProSubtitle => 'Ayda bir kez ödeme';

  @override
  String get yearlyPro => 'Yıllık Pro';

  @override
  String get yearlyProSubtitle => 'En iyi değer - %40 tasarruf';

  @override
  String get restorePurchase => 'Satın Alımı Geri Yükle';

  @override
  String get subscriptionAutoRenew =>
      'Abonelik otomatik yenilenir. İstediğiniz zaman iptal edebilirsiniz.';

  @override
  String get productsLoadError =>
      'Ürünler yüklenemedi. Lütfen internet bağlantınızı kontrol edin.';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get purchaseInProgress => 'Satın alma işlemi sürüyor...';

  @override
  String get upgradedToProMessage => 'Pro\'ya yükseltildiniz! Teşekkürler.';

  @override
  String get restoringPurchases => 'Satın alımlar geri yükleniyor...';
}
