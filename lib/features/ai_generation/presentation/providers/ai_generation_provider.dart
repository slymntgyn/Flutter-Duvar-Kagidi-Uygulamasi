import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';

/// AI gorsel uretim durumu.
class AIGenerationState {
  final bool isGenerating;
  final Uint8List? generatedImageBytes;
  final String? error;

  const AIGenerationState({
    this.isGenerating = false,
    this.generatedImageBytes,
    this.error,
  });

  AIGenerationState copyWith({
    bool? isGenerating,
    Uint8List? generatedImageBytes,
    String? error,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return AIGenerationState(
      isGenerating: isGenerating ?? this.isGenerating,
      generatedImageBytes:
          clearImage ? null : (generatedImageBytes ?? this.generatedImageBytes),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// AI gorsel uretim provider'i.
final aiGenerationProvider =
    StateNotifierProvider<AIGenerationNotifier, AIGenerationState>(
        (ref) => AIGenerationNotifier(ref));

class AIGenerationNotifier extends StateNotifier<AIGenerationState> {
  final Ref _ref;

  AIGenerationNotifier(this._ref) : super(const AIGenerationState());

  Future<void> generate(GenerationRequest request) async {
    state = state.copyWith(
        isGenerating: true, clearImage: true, clearError: true);

    try {
      final service = _ref.read(aiImageServiceProvider);
      final imageBytes = await service.generateImage(request);

      state = state.copyWith(
        isGenerating: false,
        generatedImageBytes: imageBytes,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const AIGenerationState();
  }
}
