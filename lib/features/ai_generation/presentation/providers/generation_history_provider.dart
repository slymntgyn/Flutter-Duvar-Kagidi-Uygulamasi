import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:senseriduvarkagidi/core/constants/app_constants.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_history_entry.dart';

/// AI uretim gecmisi provider'i.
/// Gorselleri temp dosyalara kaydeder, memory'de sadece path tutar.
final generationHistoryProvider = StateNotifierProvider<
    GenerationHistoryNotifier,
    List<GenerationHistoryEntry>>((ref) => GenerationHistoryNotifier());

class GenerationHistoryNotifier
    extends StateNotifier<List<GenerationHistoryEntry>> {
  GenerationHistoryNotifier() : super([]);

  /// Yeni uretilen gorseli gecmise ekler.
  /// Gorsel temp dosyaya kaydedilir, bellekte tutulmaz.
  Future<void> addEntry(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'ai_gen_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(imageBytes);

    final entry = GenerationHistoryEntry(
      filePath: file.path,
      createdAt: DateTime.now(),
    );

    final newList = [entry, ...state];

    // Limit asimi kontrolu - eski dosyalari temizle
    if (newList.length > AppConstants.maxGenerationHistory) {
      final toRemove = newList.sublist(AppConstants.maxGenerationHistory);
      for (final old in toRemove) {
        final oldFile = File(old.filePath);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      }
    }

    state = newList.take(AppConstants.maxGenerationHistory).toList();
  }
}

