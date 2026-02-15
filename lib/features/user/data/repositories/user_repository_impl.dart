import 'dart:convert';

import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/failures.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/user/data/models/user_model.dart';
import 'package:senseriduvarkagidi/features/user/domain/entities/user.dart';
import 'package:senseriduvarkagidi/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final DioClient _dioClient;

  UserRepositoryImpl(this._dioClient);

  @override
  Future<Result<User>> getUser(String deviceId) async {
    try {
      final response = await _dioClient.get(
          ApiConstants.getUser(deviceId));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.data.toString()) as Map<String, dynamic>;
        final user = UserModel.fromJson(json);
        return Success(user);
      }
      return Error(ServerFailure(
        'Kullanıcı bilgileri yüklenemedi',
        statusCode: response.statusCode,
      ));
    } catch (e) {
      return Error(NetworkFailure('Kullanıcı bilgileri hatası: $e'));
    }
  }
}
