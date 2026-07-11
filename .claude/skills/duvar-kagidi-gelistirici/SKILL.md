---
name: duvar-kagidi-gelistirici
description: 4K-HD Duvar Kağıtları Flutter uygulamasının (senseriduvarkagidi, Google Play'de yayında) mimari haritası, geliştirme kuralları ve Play Store yayınlama süreci. C:\Projects\Flutter-Duvar-Kagidi-Uygulamasi altında HERHANGİ bir iş yaparken MUTLAKA kullan — yeni özellik, hata düzeltme, AI görsel üretimi, premium/satın alma, favoriler, kategori/duvar kağıdı ekranları, Riverpod provider, sürüm yükseltme, appbundle build, Play Store yayını, AdMob, api.suleymanturan.com backend entegrasyonu konularının herhangi biri geçtiğinde tetiklenir. Kullanıcı "duvar kağıdı uygulaması", "release al", "play store'a yükle", "versiyon artır" dese bile kullan.
---

# 4K-HD Duvar Kağıtları — Geliştirici Rehberi

Google Play'de yayında, gerçek kullanıcı tabanı olan Flutter duvar kağıdı uygulaması.
**Her değişiklik geriye dönük uyumlu olmalı.** Paket: `com.benim.ilk.uygulamam.senseriduvarkagidi`.

> NOT: `.github/copilot-instructions.md` içindeki klasör yapısı (lib/models, providers, ChangeNotifier) ESKİDİR.
> Güncel mimari aşağıdadır; çelişki olursa bu skill geçerlidir.

## Teknoloji Yığını
- Flutter 3.32.x / Dart null-safety
- State: **Riverpod** (`flutter_riverpod`) — yeni kod Riverpod ile yazılır; `provider` paketi legacy, migration sonrası kalkacak
- Mimari: Clean Architecture (feature bazlı: `data / domain / presentation`)
- HTTP: `dio` (core/network/dio_client.dart), görsel cache: `cached_network_image`
- Lokal depo: `shared_preferences` (anahtarlar `AppConstants.keyXxx`)
- Monetizasyon: `google_mobile_ads` (AdMob, App ID AndroidManifest'te) + `in_app_purchase` (premium abonelik)
- Test: `flutter_test` + `mocktail`

## Klasör Haritası (güncel)
```
lib/
├── main.dart
├── core/
│   ├── constants/        # api_constants.dart (tüm endpoint'ler), app_constants.dart
│   ├── di/providers.dart # Riverpod DI — servis/repo bağlama noktası
│   ├── errors/           # exceptions, failures, Result tipi
│   ├── network/          # dio_client, network_info
│   ├── theme/            # Material 3 tema + theme_provider
│   └── widgets/          # error_view, loading_overlay, wallpaper_location_dialog
├── features/
│   ├── ai_generation/    # AI görsel üretimi (OpenRouter + OpenAI + Pollinations, failover)
│   ├── favorites/        # Favoriler
│   ├── home/             # Ana ekran (explore / categories / favorites sekmeleri)
│   ├── premium/          # Premium durum + paywall
│   ├── purchase/         # in_app_purchase servisi
│   ├── settings/         # Uygulama ayarları
│   ├── splash/           # Açılış
│   ├── user/             # Cihaz ID bazlı kullanıcı
│   └── wallpaper/        # Kategori + görsel listeleme + detay
├── ek/, model/, Screens/ # LEGACY — mümkünse dokunma, yeni kod features/ altına
test/
├── unit/                 # birim testler
└── *.dart                # provider/kural testleri
```

## Backend / API
- Tek host: `https://api.suleymanturan.com` (`ApiConstants.baseUrl`) — tüm endpoint'ler `lib/core/constants/api_constants.dart` içinde tanımlı, yeni endpoint oraya eklenir.
- **AI API anahtarları koda yazılmaz** — backend'den `/api/ayar` ile gelir (`settings.aiApiKey`), `core/di/providers.dart` servise enjekte eder.
- AI sağlayıcı seçimi `AI_PROVIDER` ayarı ile (openrouter / openai); failover: `failover_ai_service.dart`.
- Kullanıcı kimliği cihaz ID (`device_info_plus`), backend'de `/api/kullanici/{deviceId}`.

## Kod Kuralları
- `var` yerine açık tip; `final` tercih et
- Her `async` fonksiyonda hata yakalama; hatalar `core/errors` tiplerine map edilir, kullanıcıya Türkçe mesaj (`error_message_mapper.dart`)
- Async gap sonrası `BuildContext` kullanma — `mounted` kontrol et
- Mümkün her yerde `const` constructor; her Controller/StreamSubscription `dispose()` edilmeli
- API anahtarı / AdMob ID string literal yazılmaz
- Kullanıcıya görünen metinler Türkçe

## Doğrulama (her değişiklikten sonra)
```
flutter analyze          # sıfır issue beklenir (~1-2 dk sürer)
flutter test             # tüm testler geçmeli
```
Yeni hata düzeltmesi/özellik için mümkünse `test/unit/` altına test ekle.

## Play Store Yayınlama Süreci

İmzalama hazırdır: `android/key.properties` + `android/app/upload-keystore.jks` (repoya commit etme, .gitignore'da olmalı).

1. **Sürüm artır** — `pubspec.yaml` içindeki `version: X.Y.Z+N`:
   - Hata düzeltme → patch artar (1.0.39 → 1.0.40), özellik → minor artar
   - Build numarası `+N` HER yayında mutlaka +1 artar (Play Console aynı versionCode'u reddeder)
2. **Doğrula** — `flutter analyze` + `flutter test` temiz olmalı
3. **Build al**:
   ```
   flutter build appbundle --release
   ```
   Çıktı: `build\app\outputs\bundle\release\app-release.aab`
4. **Commit + tag** — sürüm artışını commit et (mevcut gelenek: kısa Türkçe mesajlar)
5. **Play Console'a yükle** — kullanıcı https://play.google.com/console üzerinden .aab dosyasını
   yeni sürüm (production/internal test) olarak yükler; sürüm notlarını Türkçe hazırla ve kullanıcıya ver.
   Claude Play Console'a otomatik yükleme yapmaz — dosya yolunu ve sürüm notlarını hazırlayıp teslim eder.

### Play politika hatırlatmaları
- targetSdk 36 / minSdk 24 — Play'in güncel targetSdk şartını sürüm yükseltmeden önce kontrol et
- İzinsiz arka plan veri toplama yok; reklam içerik gibi gösterilmez; telifsiz görsel kullanılmaz
- Premium/abonelik akışı değişirse Play Billing politikalarını gözden geçir

## Bilinen Tuzaklar
- `lib/ek/`, `lib/model/`, `lib/Screens/` legacy klasörlerdir; buradaki kod `features/` ile paralel yaşıyor — davranış değiştirirken iki tarafı da kontrol et.
- Bazı kullanıcı metinleri bilinçli olarak Türkçe karaktersiz yazılmış ("Gunluk limitiniz doldu") — mevcut dosyanın stilini koru, toplu "düzeltme" yapma.
- `wallpaper_manager_plus` major sürüm geride (1.x kullanılıyor, 2.x mevcut) — yükseltme davranış kırabilir, bilinçli karar olmadan yükseltme.
- AI hata mesajları ekranda string içeriğine göre sınıflandırılıyor (`ai_generation_screen.dart`) — AIServiceException mesajlarını değiştirirsen ekrandaki eşleşmeleri de güncelle ve `test/unit/openrouter_ai_service_error_mapping_test.dart` testini koştur.
