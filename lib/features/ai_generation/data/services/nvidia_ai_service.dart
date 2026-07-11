import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/ai_generation/data/services/prompt_enhancer.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/services/ai_image_service.dart';

/// NVIDIA NIM (build.nvidia.com) gorsel uretim servisi.
///
/// Varsayilan model FLUX.1-schnell'dir; backend farkli bir NVIDIA modeli
/// (or. flux.1-dev, stabilityai/stable-diffusion-xl) gonderirse o kullanilir.
/// API anahtari backend'den ('/api/ayar') gelir ve `nvapi-` ile baslar.
///
/// Retry ve timeout DioClient tarafindan saglanir.
class NvidiaImageService implements AIImageService {
  final DioClient _dioClient;
  final String _apiKey;
  final String _model;

  NvidiaImageService({
    required DioClient dioClient,
    required String apiKey,
    String model = ApiConstants.defaultNvidiaModel,
  })  : _dioClient = dioClient,
        _apiKey = apiKey,
        // NVIDIA model kimlikleri 'org/model' formatindadir (or.
        // black-forest-labs/flux.1-schnell). '/' icermeyen degerler
        // (dall-e-3, gpt-image-1 gibi eski OpenAI modelleri) NVIDIA'da
        // gecersizdir; bu durumda varsayilan flux modeline duseriz.
        _model = model.trim().contains('/')
            ? model.trim()
            : ApiConstants.defaultNvidiaModel;

  @override
  String get serviceId => 'nvidia';

  @override
  Future<bool> isAvailable() async => _apiKey.isNotEmpty;

  @override
  Future<Uint8List> generateImage(GenerationRequest request) async {
    final prompt = PromptEnhancer.enhance(request);
    final size = _resolveSize(request.width, request.height);

    try {
      final response = await _dioClient.externalPost(
        ApiConstants.nvidiaImageGeneration(_model),
        data: {
          'prompt': prompt,
          'mode': 'base',
          'cfg_scale': 3.5,
          'width': size.$1,
          'height': size.$2,
          'seed': 0,
          'steps': 4,
        },
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return _extractImageBytes(response.data);
      }

      throw AIServiceException('AI API isteği başarısız: ${response.statusCode}');
    } on AIServiceException {
      rethrow;
    } on NetworkException catch (error) {
      throw AIServiceException('İnternet bağlantısı sorunu: ${error.message}');
    } on ServerException catch (error) {
      throw _mapStatus(error.statusCode);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        throw AIServiceException(
            'İnternet bağlantısı sorunu: ${error.message ?? 'Ağ hatası'}');
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        throw _mapStatus(statusCode);
      }
      throw AIServiceException('AI servis hatası: ${error.message ?? error}');
    } catch (error) {
      throw AIServiceException('AI servis hatası: $error');
    }
  }

  /// HTTP durum kodunu kullaniciya gosterilecek Turkce mesaja cevirir.
  AIServiceException _mapStatus(int? statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return const AIServiceException(
          'AI API anahtarı geçersiz veya yetkisiz (401/403)');
    }
    if (statusCode == 429) {
      return const AIServiceException('AI istek limiti aşıldı (429)');
    }
    if (statusCode != null && statusCode >= 500) {
      return AIServiceException(
          'AI servisinde geçici sunucu hatası ($statusCode)');
    }
    return AIServiceException('AI API isteği başarısız (${statusCode ?? '-'})');
  }

  /// Istenen boyutu NVIDIA modellerinin kabul ettigi araliga (64'un kati,
  /// 512-1024) sikistirip dikey duvar kagidi oranini korur.
  (int, int) _resolveSize(double reqWidth, double reqHeight) {
    final w = reqWidth > 0 ? reqWidth : 1080;
    final h = reqHeight > 0 ? reqHeight : 1920;
    final aspect = w / h;

    // Uzun kenar 1024 olacak sekilde olcekle (duvar kagidi genelde dikey).
    int width;
    int height;
    if (aspect <= 1) {
      height = 1024;
      width = (1024 * aspect).round();
    } else {
      width = 1024;
      height = (1024 / aspect).round();
    }
    return (_snap(width), _snap(height));
  }

  int _snap(int value) {
    final rounded = (value / 64).round() * 64;
    return rounded.clamp(512, 1024);
  }

  /// NVIDIA gorsel yanitlarinin bilinen tum sekillerinden ham byte cikarir:
  /// - `artifacts[0].base64`        (FLUX / SDXL genai endpoint)
  /// - `image` (data-url veya base64)
  /// - `data[0].b64_json` / `data[0].url` (OpenAI uyumlu endpoint)
  Future<Uint8List> _extractImageBytes(dynamic responseData) async {
    if (responseData is! Map) {
      throw const AIServiceException('Geçersiz API yanıtı');
    }

    // 1) artifacts[].base64
    final artifacts = responseData['artifacts'];
    if (artifacts is List && artifacts.isNotEmpty) {
      final first = artifacts.first;
      if (first is Map) {
        final b64 = first['base64'] ?? first['b64_json'];
        if (b64 is String && b64.isNotEmpty) {
          return _decodeBase64(b64);
        }
      }
    }

    // 2) image alani (data-url veya saf base64)
    final image = responseData['image'];
    if (image is String && image.isNotEmpty) {
      return _decodeBase64(image);
    }

    // 3) OpenAI uyumlu: data[].b64_json / data[].url
    final data = responseData['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        final b64 = first['b64_json'];
        if (b64 is String && b64.isNotEmpty) {
          return _decodeBase64(b64);
        }
        final url = first['url'];
        if (url is String && url.isNotEmpty) {
          return _downloadImage(url);
        }
      }
    }

    throw const AIServiceException('API yanıtında görsel bulunamadı');
  }

  Uint8List _decodeBase64(String raw) {
    var value = raw.trim();
    // data:image/png;base64,XXXX -> XXXX
    final comma = value.indexOf(',');
    if (value.startsWith('data:') && comma != -1) {
      value = value.substring(comma + 1);
    }
    try {
      return base64Decode(value);
    } catch (_) {
      throw const AIServiceException('Geçerli base64 görsel bulunamadı');
    }
  }

  Future<Uint8List> _downloadImage(String url) async {
    final response = await _dioClient.externalGet<List<int>>(
      url,
      responseType: ResponseType.bytes,
    );
    final raw = response.data;
    if (raw is Uint8List) return raw;
    if (raw is List<int>) return Uint8List.fromList(raw);
    throw const AIServiceException('AI görsel indirilemedi');
  }
}
