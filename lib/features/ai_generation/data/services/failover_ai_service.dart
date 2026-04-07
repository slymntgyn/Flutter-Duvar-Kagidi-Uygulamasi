import 'dart:typed_data';

import 'package:senseriduvarkagidi/core/errors/exceptions.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/services/ai_image_service.dart';

/// Birden fazla AI servisini failover mekanizmasi ile sarar.
/// Ilk servis basarisiz olursa siradakine gecer.
class FailoverAIService implements AIImageService {
  final List<AIImageService> _services;

  FailoverAIService(this._services);

  @override
  String get serviceId => 'failover';

  @override
  Future<bool> isAvailable() async {
    for (final service in _services) {
      if (await service.isAvailable()) return true;
    }
    return false;
  }

  @override
  Future<Uint8List> generateImage(GenerationRequest request) async {
    AIServiceException? lastError;

    for (final service in _services) {
      if (!await service.isAvailable()) continue;

      try {
        return await service.generateImage(request);
      } catch (e) {
        lastError = AIServiceException(
            '${service.serviceId}: $e');
        // Sonraki servisi dene
        continue;
      }
    }

    throw lastError ??
        const AIServiceException('Kullanılabilir AI servisi bulunamadı');
  }
}

