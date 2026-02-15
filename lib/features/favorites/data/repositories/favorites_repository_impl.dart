import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/failures.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/favorites/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final DioClient _dioClient;

  FavoritesRepositoryImpl(this._dioClient);

  @override
  Future<Result<void>> toggleFavorite(String deviceId, int imageId) async {
    try {
      final response = await _dioClient.get(
          ApiConstants.toggleFavorite(deviceId, imageId));
      if (response.statusCode == 200) {
        return const Success(null);
      }
      return Error(ServerFailure(
        'Favori işlemi başarısız',
        statusCode: response.statusCode,
      ));
    } catch (e) {
      return Error(NetworkFailure('Favori işlemi hatası: $e'));
    }
  }
}
