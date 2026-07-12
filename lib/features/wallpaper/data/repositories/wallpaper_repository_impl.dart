import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/utils/gallery_saver.dart';
import 'package:senseriduvarkagidi/core/errors/failures.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/wallpaper/data/models/wallpaper_image_model.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_image.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_location.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/repositories/wallpaper_repository.dart';

class WallpaperRepositoryImpl implements WallpaperRepository {
  final DioClient _dioClient;

  WallpaperRepositoryImpl(this._dioClient);

  @override
  Future<Result<List<WallpaperImage>>> getWallpapers() async {
    try {
      final response = await _dioClient.get(ApiConstants.getImages);
      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.data.toString()) as List;
        final images = jsonList
            .map((e) => WallpaperImageModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Success(images);
      }
      return Error(ServerFailure(
        'images yüklenemedi',
        statusCode: response.statusCode,
      ));
    } catch (e) {
      return Error(NetworkFailure('images yüklenirken hata: $e'));
    }
  }

  @override
  Future<Result<void>> setWallpaper(
      String imageUrl, WallpaperLocation location) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(imageUrl);
      final result = await WallpaperManagerPlus()
          .setWallpaper(file, location.value);

      if (result == null || result.isEmpty || result.contains('success')) {
        return const Success(null);
      }
      return Error(ServerFailure('Duvar kağıdı ayarlanamadı: $result'));
    } catch (e) {
      return Error(ServerFailure('Duvar kağıdı ayarlanırken hata: $e'));
    }
  }

  @override
  Future<Result<void>> downloadWallpaper(String imageUrl) async {
    try {
      final response = await _dioClient.externalGet<List<int>>(
        imageUrl,
        responseType: ResponseType.bytes,
      );

      final Uint8List imageBytes = Uint8List.fromList(response.data as List<int>);

      final now = DateTime.now();
      final saved = await GallerySaver.saveImage(
        imageBytes,
        name: 'wallpaper_${now.millisecondsSinceEpoch}',
      );

      if (saved) {
        return const Success(null);
      }
      return const Error(
          PermissionFailure('Galeriye kaydedilemedi veya izin verilmedi'));
    } catch (e) {
      return Error(ServerFailure('İndirme hatası: $e'));
    }
  }

  @override
  Future<Result<void>> logAction(
      String deviceId, String action, int imageId) async {
    try {
      await _dioClient.get(
          ApiConstants.logAction(deviceId, action, imageId));
      return const Success(null);
    } catch (e) {
      // Log hatalari uygulamayi durdurmasın
      return const Success(null);
    }
  }
}

