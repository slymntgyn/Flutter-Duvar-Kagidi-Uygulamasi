/// Uygulama genelinde kullanilan hata turleri.
/// Domain katmaninda kullanilir, Flutter bagimliligi yoktur.
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// Sunucu kaynaklı hatalar (HTTP 4xx, 5xx).
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Ag baglanti hatalari (timeout, no internet).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Yerel cache/storage hatalari.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// AI servis hatalari (generation failed, provider unavailable).
class AIServiceFailure extends Failure {
  const AIServiceFailure(super.message);
}

/// Izin hatalari (gallery, storage permission denied).
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}
