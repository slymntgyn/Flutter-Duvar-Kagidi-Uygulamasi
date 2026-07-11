import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/ai_generation/data/services/prompt_enhancer.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/services/ai_image_service.dart';

/// OpenRouter AI servisi concrete implementasyonu.
/// Retry ve timeout DioClient tarafindan saglanir.
class OpenRouterImageService implements AIImageService {
  final DioClient _dioClient;
  final String _apiKey;
  final String _model;

  OpenRouterImageService({
    required DioClient dioClient,
    required String apiKey,
    required String model,
  })  : _dioClient = dioClient,
        _apiKey = apiKey,
        _model = model;

  @override
  String get serviceId => 'openrouter';

  @override
  Future<bool> isAvailable() async {
    return _apiKey.isNotEmpty && _model.isNotEmpty;
  }

  @override
  Future<Uint8List> generateImage(GenerationRequest request) async {
    final enhancedPrompt = PromptEnhancer.enhance(request);

    try {
      final response = await _dioClient.externalPost(
        ApiConstants.openRouterImageGeneration,
        data: {
          'model': _model,
          'prompt': enhancedPrompt,
          'size': '1024x1792',
        },
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return _extractImageBytes(response.data);
      }

      throw AIServiceException('API isteği başarısız: ${response.statusCode}');
    } on AIServiceException {
      rethrow;
    } on NetworkException catch (error) {
      throw AIServiceException('İnternet bağlantısı sorunu: ${error.message}');
    } on ServerException catch (error) {
      final statusCode = error.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw const AIServiceException(
            'AI API anahtarı geçersiz veya yetkisiz (401/403)');
      }
      if (statusCode == 429) {
        throw const AIServiceException('AI istek limiti aşıldı (429)');
      }
      if (statusCode != null && statusCode >= 500) {
        throw AIServiceException(
            'AI servisinde geçici sunucu hatası ($statusCode)');
      }
      throw AIServiceException(
          'AI API isteği başarısız (${statusCode ?? '-'})');
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        throw AIServiceException(
            'İnternet bağlantısı sorunu: ${error.message ?? 'Ağ hatası'}');
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw const AIServiceException(
            'AI API anahtarı geçersiz veya yetkisiz (401/403)');
      }
      if (statusCode == 429) {
        throw const AIServiceException('AI istek limiti aşıldı (429)');
      }
      if (statusCode != null) {
        throw AIServiceException('AI API isteği başarısız ($statusCode)');
      }

      throw AIServiceException('AI servis hatası: ${error.message ?? error}');
    } catch (error) {
      throw AIServiceException('AI servis hatası: $error');
    }
  }

  Future<Uint8List> _extractImageBytes(dynamic responseData) async {
    if (responseData is! Map) {
      throw const AIServiceException('Geçersiz API yanıtı');
    }

    final data = responseData['data'];
    if (data == null || data is! List || data.isEmpty) {
      throw const AIServiceException('API yanıtında data bulunamadı');
    }

    final firstItem = data[0];
    if (firstItem is! Map) {
      throw const AIServiceException('Geçersiz OpenRouter data formatı');
    }

    final b64Json = firstItem['b64_json'];
    if (b64Json is String && b64Json.isNotEmpty) {
      return base64Decode(b64Json);
    }

    final url = firstItem['url'];
    if (url is String && url.isNotEmpty) {
      final imageResponse = await _dioClient.externalGet<List<int>>(
        url,
        responseType: ResponseType.bytes,
      );

      final rawData = imageResponse.data;
      if (rawData is Uint8List) {
        return rawData;
      }
      if (rawData is List<int>) {
        return Uint8List.fromList(rawData);
      }
      throw const AIServiceException('OpenRouter görsel indirilemedi');
    }

    final choices = responseData['choices'];
    if (choices == null || choices is! List || choices.isEmpty) {
      throw const AIServiceException('API yanıtında görsel bulunamadı');
    }

    final message = choices[0]['message'];
    if (message == null) {
      throw const AIServiceException('API yanıtında message bulunamadı');
    }

    final content = message['content'];
    String? base64String;
    if (content is String) {
      base64String = content;
    } else if (content is List) {
      for (final item in content) {
        if (item is Map &&
            item['type'] == 'image_url' &&
            item['image_url']?['url'] != null) {
          base64String = item['image_url']['url'] as String;
          break;
        }
      }
    }

    if (base64String == null) {
      throw const AIServiceException('API yanıtında görsel bulunamadı');
    }

    // data:image/xxx;base64,... formatini parse et
    final dataUrlRegex = RegExp(r'data:image\/[^;]+;base64,([A-Za-z0-9+/=]+)');
    final match = dataUrlRegex.firstMatch(base64String);
    if (match != null) {
      return base64Decode(match.group(1)!);
    }

    // Saf base64 string kontrolu
    final pureBase64Regex = RegExp(r'^[A-Za-z0-9+/]+=*$');
    if (pureBase64Regex.hasMatch(base64String.trim())) {
      return base64Decode(base64String.trim());
    }

    throw const AIServiceException('Geçerli base64 görsel bulunamadı');
  }
}
