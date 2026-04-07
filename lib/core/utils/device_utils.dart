import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:senseriduvarkagidi/core/constants/app_constants.dart';
import 'package:senseriduvarkagidi/core/storage/local_storage.dart';

/// Cihaz ID olusturma ve yonetim utility'si.
class DeviceUtils {
  DeviceUtils._();

  /// Kalici cihaz ID'si dondurur.
  /// Ilk cagrildiginda olusturulur ve SharedPreferences'a kaydedilir.
  static Future<String> getDeviceId(LocalStorage storage) async {
    String? deviceId = await storage.getString(AppConstants.keyDeviceId);

    if (deviceId == null || deviceId.isEmpty) {
      String platform = Platform.isAndroid ? 'AND' : 'IOS';
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String random = Random().nextInt(999999).toString().padLeft(6, '0');

      deviceId = '$platform-$timestamp-$random';
      await storage.setString(AppConstants.keyDeviceId, deviceId);
    }

    // SHA256 hash
    final bytes = utf8.encode(deviceId);
    final digest = sha256.convert(bytes);
    return 'CIHAZ : ${digest.toString().trim()}';
  }
}

