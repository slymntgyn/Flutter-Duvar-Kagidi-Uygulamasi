import 'dart:convert';
import 'dart:typed_data';

import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/ai_generation/data/services/prompt_enhancer.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/services/ai_image_service.dart';

/// OpenAI DALL-E AI servisi implementasyonu.
/// dall-e-3 veya dall-e-2 modeli kullanir.
class OpenAIAIService implements AIImageService {
  final DioClient _dioClient;
  final String _apiKey;
  final String _model;

  OpenAIAIService({
    required DioClient dioClient,
    required String apiKey,
    String model = 'dall-e-3',
  })  : _dioClient = dioClient,
        _apiKey = apiKey,
        _model = model;

  @override
  String get serviceId => 'openai';

  @override
  Future<bool> isAvailable() async {
    return _apiKey.isNotEmpty;
  }

  @override
  Future<Uint8List> generateImage(GenerationRequest request) async {
    final enhancedPrompt = PromptEnhancer.enhance(request);

    try {
      // DALL-E 3: 1024x1024, 1024x1792 veya 1792x1024
      // DALL-E 2: 256x256, 512x512 veya 1024x1024
      final size = _model == 'dall-e-3' ? '1024x1792' : '1024x1024';

      final response = await _dioClient.externalPost(
        ApiConstants.openAiImageGeneration,
        data: {
          'model': _model,
          'prompt': enhancedPrompt,
          'n': 1,
          'size': size,
          'response_format': 'b64_json',
          'quality': _model == 'dall-e-3' ? 'standard' : null,
        }..removeWhere((_, v) => v == null),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final base64String = _extractBase64(response.data);
        return base64Decode(base64String);
      }

      throw AIServiceException(
          'OpenAI API isteği başarısız: ${response.statusCode}');
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('OpenAI servisi ile bağlantı kurulamadı: $e');
    }
  }

  String _extractBase64(dynamic responseData) {
    if (responseData is! Map) {
      throw const AIServiceException('Geçersiz OpenAI API yanıtı');
    }

    final data = responseData['data'];
    if (data == null || data is! List || data.isEmpty) {
      throw const AIServiceException('OpenAI API yanıtında data bulunamadı');
    }

    final firstItem = data[0];
    if (firstItem is! Map) {
      throw const AIServiceException('Geçersiz OpenAI data formatı');
    }

    // b64_json formatinda donus
    final b64Json = firstItem['b64_json'];
    if (b64Json != null && b64Json is String && b64Json.isNotEmpty) {
      return b64Json;
    }

    // URL formatinda donus (b64_json yerine url donuyorsa)
    final url = firstItem['url'];
    if (url != null && url is String) {
      throw const AIServiceException(
          'OpenAI URL formatı desteklenmiyor, b64_json kullanın');
    }

    throw const AIServiceException('OpenAI API yanıtında görsel bulunamadı');
  }
}

