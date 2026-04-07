import 'package:photo_manager/photo_manager.dart';

/// Izin yonetimi utility'si.
class PermissionUtils {
  PermissionUtils._();

  /// Galeri yazma izni kontrol eder ve ister.
  static Future<bool> requestGalleryPermission() async {
    final ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth || ps == PermissionState.limited;
  }
}

