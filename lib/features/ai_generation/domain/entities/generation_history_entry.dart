/// AI uretim gecmisi girisi.
/// Gorselin kendisi yerine dosya yolunu tutar (memory optimization).
class GenerationHistoryEntry {
  final String filePath;
  final DateTime createdAt;

  const GenerationHistoryEntry({
    required this.filePath,
    required this.createdAt,
  });
}

