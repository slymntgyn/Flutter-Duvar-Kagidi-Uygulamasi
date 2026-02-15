import 'dart:convert';

import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/failures.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/settings/data/models/settings_model.dart';
import 'package:senseriduvarkagidi/features/settings/domain/entities/app_settings.dart';
import 'package:senseriduvarkagidi/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final DioClient _dioClient;

  SettingsRepositoryImpl(this._dioClient);

  @override
  Future<Result<AppSettings>> getSettings() async {
    try {
      final response = await _dioClient.get(ApiConstants.getSettings);
      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.data.toString()) as List;
        final settingsList = jsonList
            .map((e) => e as Map<String, dynamic>)
            .toList();
        final settings = SettingsModel.fromSettingsList(settingsList);
        return Success(settings);
      }
      return Error(ServerFailure(
        'Ayarlar yüklenemedi',
        statusCode: response.statusCode,
      ));
    } catch (e) {
      return Error(NetworkFailure('Ayarlar yüklenirken hata: $e'));
    }
  }
}
