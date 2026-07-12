import 'dart:typed_data';

import 'package:gal/gal.dart';

/// Görseli cihaz galerisine kaydeder.
///
/// `gal` paketi MediaStore kullanır; Android 10+ (API 29+) hiçbir izin
/// istemez, API 28 ve altında yalnızca WRITE_EXTERNAL_STORAGE ister.
/// READ_MEDIA_IMAGES/VIDEO gibi kısıtlı izinleri KULLANMAZ (Google Play
/// Foto/Video izin politikasına uyum için photo_manager yerine kullanıldı).
class GallerySaver {
  GallerySaver._();

  /// Ham byte'ları galeriye kaydeder.
  /// Başarılıysa `true`, izin verilmediyse veya hata olduysa `false` döner.
  static Future<bool> saveImage(Uint8List bytes, {required String name}) async {
    try {
      if (!await Gal.hasAccess()) {
        final granted = await Gal.requestAccess();
        if (!granted) return false;
      }
      await Gal.putImageBytes(bytes, name: name);
      return true;
    } on GalException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
