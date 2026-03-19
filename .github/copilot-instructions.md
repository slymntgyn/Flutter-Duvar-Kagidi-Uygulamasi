# Wallpaper App — Copilot Agent Instructions

## Proje bağlamı
- Flutter 3.x, Dart null-safety
- Google Play'de yayında, mevcut kullanıcı var
- Mimari: Provider + Repository pattern

## Ajan rolleri
- **Plan**: Kullanıcı isteğini al, dosya listesi + adım çıkar, onay iste
- **Feature**: lib/screens, lib/widgets, lib/services altına yaz
- **Review**: Her değişiklik sonrası performance + null-safety kontrol et
- **Test**: Her yeni widget için test/ altına widget testi ekle
- **Release**: pubspec.yaml versiyon güncelle, CHANGELOG.md yaz
- **Store**: Metadata İngilizce + Türkçe hazırla
- **Monetizasyon**: AdMob unit ID'leri constants.dart'ta

## Kurallar
- Mevcut kodu kırmadan ekle
- Her değişiklik için önce plan sun, sonra yaz
- Play Store politikasına aykırı hiçbir şey ekleme
```

**Kullanım şekli:**

Copilot Chat'i açıp `@workspace` ile konuşursun, ajan rolü otomatik devreye girer. Örnek:
```
@workspace yeni bir "Koleksiyon" özelliği eklemek istiyorum. 
Önce plan çıkar, onayımı bekle.