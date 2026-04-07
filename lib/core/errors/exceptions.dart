/// Sunucu kaynaklı exception.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Ag baglanti exception.
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Cache/storage exception.
class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// AI servis exception.
class AIServiceException implements Exception {
  final String message;
  const AIServiceException(this.message);

  @override
  String toString() => 'AIServiceException: $message';
}

