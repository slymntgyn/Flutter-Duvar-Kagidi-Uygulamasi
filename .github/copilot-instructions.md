# Wallpaper App — Copilot Instructions

## Proje Özeti
Flutter 3.x / Dart null-safety ile yazılmış, Google Play'de yayında bir duvar kağıdı uygulaması.
Mevcut kullanıcı tabanı var — her değişiklik geriye dönük uyumlu olmalı.

## Teknoloji Yığını
- State: Provider + ChangeNotifier
- Mimari: Repository Pattern
- HTTP: dio
- Görsel cache: cached_network_image
- Lokal depo: shared_preferences + hive
- Reklam: google_mobile_ads (AdMob)
- Test: flutter_test + mocktail

## Proje Klasör Yapısı
```
lib/
├── main.dart
├── constants.dart          # AdMob ID, API key sabitleri
├── models/                 # Veri modelleri (Wallpaper, Category, Collection…)
├── repositories/           # API + lokal veri kaynakları
├── providers/              # ChangeNotifier sınıfları
├── screens/                # Tam ekranlar (HomeScreen, DetailScreen…)
├── widgets/                # Tekrar kullanılabilir bileşenler
├── services/               # Download, permission, analytics
└── utils/                  # Helper fonksiyonlar, extensions
test/
├── widget/
├── unit/
└── mocks/
```

## Çalışma Protokolü — ZORUNLU

### Her görevde sıra şöyle işler:
1. **PLAN** — Değiştirilecek / eklenecek dosyaları listele, adımları çıkar
2. **ONAY** — "Planı onaylıyor musun?" diye sor, kullanıcı "evet" demeden kod yazma
3. **UYGULA** — Sadece planda belirtilen dosyalara dokun
4. **KONTROL** — Null-safety + performance sorunlarını raporla

### Plan formatı her zaman şu şablona uymalı:
```
## Plan: [Özellik Adı]

### Etkilenecek dosyalar
- [YENİ] lib/models/collection.dart
- [DEĞİŞECEK] lib/screens/home_screen.dart — navigasyon eklenir
- [YENİ] test/widget/collection_card_test.dart

### Adımlar
1. Model oluştur
2. Repository metodu ekle
3. Provider güncelle
4. UI yaz
5. Test yaz

### Riskler
- HomeScreen'deki mevcut grid bozulabilir → snapshot testi eklenecek

Onaylıyor musun? (evet / hayır / düzenle)
```

## Kod Kuralları

- `var` kullanma, tip tanımla
- Her `async` fonksiyon `try/catch` içersin
- `BuildContext` async gap'te kullanılmayacak — `mounted` kontrol et
- Widget'larda `const` constructor zorunlu (mümkün olan her yerde)
- `dispose()` — her Controller ve StreamSubscription temizlenmeli
- API anahtarı ve AdMob ID asla string literal olarak yazılmayacak, `Constants.xxx` üzerinden referans alınacak

## Google Play Politikası — Yasaklar
- Kullanıcı izni olmadan arka planda veri toplama
- Yanıltıcı reklam yerleşimi (reklamın içerik gibi görünmesi)
- Telif hakkı belirsiz görseller
- Çocuklara yönelik içerikte reklam

## Monetizasyon Şeması
```dart
// constants.dart içinde bu yapı korunmalı:
class Constants {
  // AdMob
  static const String bannerAdUnitId   = 'ca-app-pub-XXXX/XXXX'; // Banner
  static const String interstitialAdId = 'ca-app-pub-XXXX/XXXX'; // Geçiş
  static const String rewardedAdId     = 'ca-app-pub-XXXX/XXXX'; // Ödüllü

  // API
  static const String unsplashKey = String.fromEnvironment('UNSPLASH_KEY');
  static const String pexelsKey   = String.fromEnvironment('PEXELS_KEY');
}
```

## Versiyon & Release Kuralları
- `pubspec.yaml` versiyonu: `major.minor.patch+buildNumber`
- Her özellik → minor artar (1.2.0 → 1.3.0)
- Her hata düzeltme → patch artar (1.2.0 → 1.2.1)
- CHANGELOG.md formatı:
```
## [1.3.0] - 2025-XX-XX
### Eklendi
- Koleksiyon özelliği
### Düzeltildi
- …
```