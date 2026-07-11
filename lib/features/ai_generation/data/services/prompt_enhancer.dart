import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';

/// Kullanıcı prompt'unu görsel üretim modeli için optimize eder.
/// Konu + seçilen stil + kalite eklerini birleştirir.
class PromptEnhancer {
  PromptEnhancer._();

  /// Metinden-görsele model (NVIDIA FLUX / SDXL) için prompt üretir.
  static String enhance(GenerationRequest request) {
    final buffer = StringBuffer();

    buffer.write(request.prompt.trim());
    buffer.write(_getStyleModifier(request.style));
    buffer.write(
      ', masterpiece, best quality, ultra detailed, sharp focus, '
      'vertical mobile wallpaper, 4k',
    );

    return buffer.toString();
  }

  static String _getStyleModifier(String style) {
    return switch (style.toLowerCase()) {
      'gercekci' => ', photorealistic, high quality, detailed, 8K resolution',
      'anime' => ', anime art style, manga, vibrant colors, cel shading',
      'dijital sanat' => ', digital art, concept art, cinematic lighting',
      'fantastik' => ', fantasy art, magical, mystical, epic atmosphere',
      'minimalist' => ', minimalist design, clean, simple, modern, geometric',
      'soyut' => ', abstract art, geometric shapes, vibrant colors, modern design',
      'dogal' => ', natural landscape, organic, peaceful, serene, beautiful',
      'uzay' => ', space scene, galaxy, cosmic, nebula, stars, sci-fi',
      'retro' => ', retro style, vintage, film grain, nostalgic, 80s aesthetic',
      'suluboya' => ', watercolor painting, artistic, soft brushstrokes, pastel',
      // Eski stil adları (geriye dönük uyumluluk)
      'gerçekçi' => ', photorealistic, high quality, detailed, 8K resolution',
      'doğa' => ', natural landscape, organic, peaceful, serene, beautiful',
      'siberpunk' => ', cyberpunk style, neon lights, futuristic, dark atmosphere',
      _ => ', artistic, high quality',
    };
  }
}

