import 'dart:io';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ChallengeValidationResult {
  final bool passed;
  final Map<String, double> scores; // label -> confidenza [0..1]
  const ChallengeValidationResult(this.passed, this.scores);
}

class ChallengeValidator {
  /// Valida l'immagine per la challenge usando ML Kit.
  /// Passa se almeno una delle `expectedLabels` compare con confidenza >= `minConfidence`.
  Future<ChallengeValidationResult> validate(Challenge challenge, File imageFile) async {
    final expected = challenge.expectedLabels.map((e) => e.toLowerCase()).toList();
    if (expected.isEmpty) {
      return const ChallengeValidationResult(false, {});
    }

    // Prefiltro più basso della soglia finale, per non perdere label borderline
    final prefilter = challenge.minConfidence.clamp(0.3, 0.6);

    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: prefilter),
    );

    try {
      final input = InputImage.fromFile(imageFile);
      final labels = await labeler.processImage(input);

      final scores = <String, double>{};
      for (final l in labels) {
        scores[l.label.toLowerCase()] = l.confidence;
      }

      final ok = expected.any((w) => (scores[w] ?? 0.0) >= challenge.minConfidence);
      return ChallengeValidationResult(ok, scores);
    } finally {
      await labeler.close();
    }
  }
}
