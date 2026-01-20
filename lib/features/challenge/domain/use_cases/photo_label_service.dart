import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class PhotoLabelService {
  final ImageLabeler _labeler;

  PhotoLabelService({double confidence = 0.6})
      : _labeler = ImageLabeler(
          options: ImageLabelerOptions(confidenceThreshold: confidence),
        );

  Future<Set<String>> labelsFor(File file) async {
    final input = InputImage.fromFile(file);
    final labels = await _labeler.processImage(input);
    // MLKit restituisce etichette in EN (es. "Flamingo", "Bird", ...)
    return labels.map((l) => _norm(l.label)).toSet();
  }

  String _norm(String s) => s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[àáâãä]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôõö]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  void dispose() => _labeler.close();
}
