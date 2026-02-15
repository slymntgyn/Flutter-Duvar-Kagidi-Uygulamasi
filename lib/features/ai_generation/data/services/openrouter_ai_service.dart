import 'dart:convert';
import 'dart:typed_data';

import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/ai_generation/data/services/prompt_enhancer.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/services/ai_image_service.dart';

/// OpenRouter AI servisi concrete implementasyonu.
/// Retry ve timeout DioClient tarafindan saglanir.
class OpenRouterAIService implements AIImageService {
  final DioClient _dioClient;
  final String _apiKey;
  final String _model;

  OpenRouterAIService({
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
        ApiConstants.openRouterChatCompletions,
        data: {
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': enhancedPrompt},
              ],
            }
          ],
        },
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final base64String = _extractBase64FromResponse(response.data);
        // base64 string -> Uint8List (memory-safe)
        return base64Decode(base64String);
      }

      throw AIServiceException(
          'API isteği başarısız: ${response.statusCode}');
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('AI servisi ile bağlantı kurulamadı: $e');
    }
  }

  String _extractBase64FromResponse(dynamic responseData) {
    if (responseData is! Map) {
      throw const AIServiceException('Geçersiz API yanıtı');
    }

    final choices = responseData['choices'];
    if (choices == null || choices is! List || choices.isEmpty) {
      throw const AIServiceException('API yanıtında choices bulunamadı');
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
      for (var item in content) {
        if (item is Map &&
            item['type'] == 'image_url' &&
            item['image_url']?['url'] != null) {
          base64String = item['image_url']['url'] as String;
          break;
        }
      }
    }

    if (base64String == null) {
      throw const AIServiceException(
          'API yanıtında görsel bulunamadı');
    }

    // data:image/xxx;base64,... formatini parse et
    final dataUrlRegex =
        RegExp(r'data:image\/[^;]+;base64,([A-Za-z0-9+/=]+)');
    final match = dataUrlRegex.firstMatch(base64String);
    if (match != null) return match.group(1)!;

    // Saf base64 string kontrolu
    final pureBase64Regex = RegExp(r'^[A-Za-z0-9+/]+=*$');
    if (pureBase64Regex.hasMatch(base64String.trim())) {
      return base64String.trim();
    }

    throw const AIServiceException(
        'Geçerli base64 görsel bulunamadı');
  }
}
