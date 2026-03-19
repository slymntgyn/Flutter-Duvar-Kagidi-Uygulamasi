import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';

/// Kullanıcı prompt'unu AI modeli için optimize eder.
/// Pollinations için ayrı, OpenRouter için ayrı prompt formatı kullanılır.
class PromptEnhancer {
  PromptEnhancer._();

  /// OpenRouter (chat completions) için prompt üretir.
  static String enhance(GenerationRequest request) {
    final buffer = StringBuffer();

    buffer.write(
      'Generate a high quality mobile wallpaper image. '
      'Return ONLY base64 image data, no text explanation. '
      'Dimensions: width=${request.width.toInt()}, height=${request.height.toInt()}. '
      'Subject: ${request.prompt} ',
    );

    buffer.write(_getStyleModifier(request.style));

    buffer.write(
      ', masterpiece, best quality, ultra detailed, sharp focus, '
      'wallpaper format. Return base64 only, no conversation.',
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
