import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/ai_generation/data/services/prompt_enhancer.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/services/ai_image_service.dart';

/// OpenAI DALL-E AI servisi implementasyonu.
/// dall-e-3 veya dall-e-2 modeli kullanir.
class OpenAIImageService implements AIImageService {
  final DioClient _dioClient;
  final String _apiKey;
  final String _model;

  OpenAIImageService({
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
      final response = await _dioClient.externalPost(
        ApiConstants.openAiImageGeneration,
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

      throw AIServiceException(
          'OpenAI API isteği başarısız: ${response.statusCode}');
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('OpenAI servisi ile bağlantı kurulamadı: $e');
    }
  }

  Future<Uint8List> _extractImageBytes(dynamic responseData) async {
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
      return base64Decode(b64Json);
    }

    // URL formatinda donus
    final url = firstItem['url'];
    if (url != null && url is String && url.isNotEmpty) {
      final imageResponse = await _dioClient.externalGet<List<int>>(
        url,
        responseType: ResponseType.bytes,
      );

      final dynamic rawData = imageResponse.data;
      if (rawData is Uint8List) {
        return rawData;
      }
      if (rawData is List<int>) {
        return Uint8List.fromList(rawData);
      }
      throw const AIServiceException('OpenAI görsel indirilemedi');
    }

    throw const AIServiceException('OpenAI API yanıtında görsel bulunamadı');
  }
}
