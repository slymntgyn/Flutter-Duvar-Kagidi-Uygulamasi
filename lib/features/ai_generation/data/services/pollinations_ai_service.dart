import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/services/ai_image_service.dart';

/// Pollinations.ai ücretsiz AI görsel üretim servisi.
/// API anahtarı GEREKMİYOR — tamamen ücretsiz.
/// https://image.pollinations.ai
class PollinationsAIService implements AIImageService {
  final DioClient _dioClient;
  final _random = Random();

  static const String _baseUrl = 'https://image.pollinations.ai/prompt';

  // Duvar kağıdı için maksimum boyutlar
  static const int _maxWidth = 1080;
  static const int _maxHeight = 1920;

  PollinationsAIService({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  String get serviceId => 'pollinations';

  /// Pollinations her zaman erişilebilir — API anahtarı gerekmez.
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<Uint8List> generateImage(GenerationRequest request) async {
    final prompt = _buildPrompt(request);
    final encodedPrompt = Uri.encodeComponent(prompt);
    final model = _getModel(request.style);
    final seed = _random.nextInt(999999);
    final width = request.width.toInt().clamp(256, _maxWidth);
    final height = request.height.toInt().clamp(256, _maxHeight);

    final url = '$_baseUrl/$encodedPrompt'
        '?width=$width'
        '&height=$height'
        '&model=$model'
        '&nologo=true'
        '&enhance=true'
        '&seed=$seed';

    try {
      final response = await _dioClient.externalGet<List<int>>(
        url,
        responseType: ResponseType.bytes,
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        // Minimum geçerli görsel boyutu kontrolü
        if (bytes.length < 1000) {
          throw const AIServiceException(
              'Geçersiz görsel yanıtı (boyut çok küçük)');
        }
        return bytes;
      }

      throw AIServiceException(
          'Pollinations API hatası: ${response.statusCode}');
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Görsel oluşturma servisi bağlantı hatası: $e');
    }
  }

  /// Stile göre Pollinations modelini seçer.
  /// flux-realism: Gerçekçi ve doğal stiller
  /// flux-anime: Anime stili
  /// flux: Genel amaçlı (dijital sanat, fantastik, vb.)
  String _getModel(String style) {
    return switch (style.toLowerCase()) {
      'gercekci' || 'dogal' => 'flux-realism',
      'anime' => 'flux-anime',
      _ => 'flux',
    };
  }

  /// Stile özgü İngilizce anahtar kelimeler ekleyerek
  /// Pollinations için optimize edilmiş prompt oluşturur.
  String _buildPrompt(GenerationRequest request) {
    final styleKw = _getStyleKeywords(request.style);
    return '${request.prompt}, mobile phone wallpaper, $styleKw, '
        'high quality, stunning, beautiful, professional';
  }

  String _getStyleKeywords(String style) {
    return switch (style.toLowerCase()) {
      'gercekci' =>
        'photorealistic, ultra detailed, 8K resolution, HDR, sharp focus',
      'anime' =>
        'anime art, manga style, vibrant colors, cel shading, detailed',
      'dijital sanat' =>
        'digital art, concept art, cinematic lighting, vivid, sharp',
      'fantastik' =>
        'fantasy art, magical, epic, mystical atmosphere, dramatic lighting',
      'minimalist' =>
        'minimalist design, clean, simple, modern, geometric, flat',
      'soyut' =>
        'abstract art, vibrant colors, geometric patterns, colorful, dynamic',
      'dogal' =>
        'nature landscape, serene, lush greenery, natural light, peaceful',
      'uzay' =>
        'outer space, galaxy, cosmic, nebula, stars, sci-fi, deep universe',
      'retro' =>
        'retro style, vintage aesthetic, film grain, 80s vibe, nostalgic',
      'suluboya' =>
        'watercolor painting, artistic brushstrokes, soft pastel colors, dreamy',
      _ => 'artistic, high quality, detailed',
    };
  }
}
