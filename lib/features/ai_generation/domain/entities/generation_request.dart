/// AI gorsel uretim istegi.
/// Pure Dart - Flutter bagimliligi yoktur.
class GenerationRequest {
  final String prompt;
  final String style;
  final double width;
  final double height;

  const GenerationRequest({
    required this.prompt,
    required this.style,
    required this.width,
    required this.height,
  });
}
