import 'dart:typed_data';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';

/// AI gorsel uretim servisi abstract interface'i.
/// Birden fazla AI provider destegi icin abstraction.
abstract class AIImageService {
  /// Prompt'tan duvar kagidi gorseli uretir.
  /// [Uint8List] olarak ham gorsel byte verisi dondurur (base64 string degil - memory icin).
  Future<Uint8List> generateImage(GenerationRequest request);

  /// Bu servisin su an kullanilabilir olup olmadigini kontrol eder.
  Future<bool> isAvailable();

  /// Servis tanimlayicisi (loglama/analytics icin).
  String get serviceId;
}
