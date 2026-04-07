import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/features/user/domain/entities/user.dart';

/// Kullanici repository interface'i.
abstract class UserRepository {
  /// Cihaz ID'si ile kullanici bilgilerini getirir.
  Future<Result<User>> getUser(String deviceId);
}

