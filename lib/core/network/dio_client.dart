import 'package:dio/dio.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/constants/app_constants.dart';
import 'package:senseriduvarkagidi/core/errors/exceptions.dart';

/// Merkezi HTTP istemcisi.
/// Tum API cagrilari bu class uzerinden yapilir.
/// Retry, timeout ve error mapping icerir.
class DioClient {
  late final Dio _dio;
  late final Dio _externalDio;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      responseType: ResponseType
          .plain, // response.data her zaman String olsun, jsonDecode ile ayristir
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    ));
    _dio.interceptors.add(_RetryInterceptor(_dio));

    _externalDio = Dio(BaseOptions(
      connectTimeout: ApiConstants.aiConnectTimeout,
      receiveTimeout: ApiConstants.aiReceiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));
    _externalDio.interceptors.add(_RetryInterceptor(_externalDio));
  }

  /// Internal API (suleymanturan.com) icin GET istegi.
  Future<Response<T>> get<T>(String path,
      {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParams);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Internal API icin POST istegi.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post<T>(path,
          data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// External API (OpenRouter vb.) icin POST istegi.
  Future<Response<T>> externalPost<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _externalDio.post<T>(
        url,
        data: data,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// External API icin GET istegi (image download vb.).
  Future<Response<T>> externalGet<T>(
    String url, {
    ResponseType? responseType,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _externalDio.get<T>(
        url,
        options:
            responseType != null ? Options(responseType: responseType) : null,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Bağlantı zaman aşımına uğradı: ${e.message}');
      case DioExceptionType.connectionError:
        return NetworkException('İnternet bağlantısı yok: ${e.message}');
      case DioExceptionType.badResponse:
        return ServerException(
          e.response?.statusMessage ?? 'Sunucu hatası',
          statusCode: e.response?.statusCode,
        );
      default:
        return ServerException('Beklenmeyen hata: ${e.message}');
    }
  }
}

/// Exponential backoff ile retry interceptor.
class _RetryInterceptor extends Interceptor {
  final Dio _dio;

  _RetryInterceptor(this._dio);

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final shouldRetry = _shouldRetry(err);
    if (!shouldRetry) {
      return handler.next(err);
    }

    for (int attempt = 0; attempt < AppConstants.maxRetryAttempts; attempt++) {
      try {
        await Future.delayed(AppConstants.retryDelays[attempt]);

        final options = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
        );

        final response = await _dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: options,
        );

        return handler.resolve(response);
      } on DioException catch (e) {
        if (attempt == AppConstants.maxRetryAttempts - 1) {
          return handler.next(e);
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

