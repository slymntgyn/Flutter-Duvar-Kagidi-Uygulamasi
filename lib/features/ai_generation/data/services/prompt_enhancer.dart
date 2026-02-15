import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';

/// Kullanici prompt'unu AI modeli icin optimize eder.
class PromptEnhancer {
  PromptEnhancer._();

  static String enhance(GenerationRequest request) {
    final buffer = StringBuffer();

    buffer.write(
      'Mobil cihazlar için yüksek kaliteli bir duvar kağıdı üret. '
      'Yalnızca görsel çıktıyı tek mesajda ver, açıklama ekleme. '
      'Ölçüler: Genişlik=${request.width.toInt()}, Yükseklik=${request.height.toInt()}. '
      'Tema: ${request.prompt} ',
    );

    // Stil bazli ek prompt
    buffer.write(_getStyleModifier(request.style));

    buffer.write(
      ', başyapıt, en iyi kalite, ultra detaylı, keskin odak, '
      'duvar kağıdı formatında. Sadece base 64 formatında veri dön. Konuşma yapma',
    );

    return buffer.toString();
  }

  static String _getStyleModifier(String style) {
    return switch (style.toLowerCase()) {
      'gerçekçi' => ', fotorealistik, yüksek kalite, detaylı, 8K çözünürlük',
      'anime' => ', anime tarzı, manga sanatı, canlı renkler',
      'soyut' => ', soyut sanat, geometrik şekiller, modern tasarım',
      'fantastik' => ', fantastik sanat, büyülü, mistik, büyüleyici',
      'siberpunk' => ', siberpunk tarzı, neon ışıklar, fütüristik, karanlık atmosfer',
      'doğa' => ', doğal manzara, organik, huzurlu, sakin, güzel',
      _ => '',
    };
  }
}
