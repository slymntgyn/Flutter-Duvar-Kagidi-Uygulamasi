import 'dart:typed_data';

/// AI gorsel uretim sonucu.
class GenerationResult {
  /// Uretilen gorselin ham byte verileri.
  final Uint8List imageBytes;

  /// Uretim zamani.
  final DateTime createdAt;

  const GenerationResult({
    required this.imageBytes,
    required this.createdAt,
  });
}

