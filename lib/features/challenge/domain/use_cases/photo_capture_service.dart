import 'dart:io';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoCaptureService {
  PhotoCaptureService(this.repo);
  final ChallengeRepository repo;

  /// Ritorna il File della foto scattata (o null se annullato / permesso negato).
  Future<File?> captureForChallenge(Challenge challenge) async {
    // 1) Permessi
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      // opzionale: apri impostazioni
      return null;
    }

    // 2) Fotocamera
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (xfile == null) return null;

    final file = File(xfile.path);

    // 1) Pubblica l’evento per i subscriber
    ChallengeEventBus.I.publish(
      PhotoCapturedEvent(file: file, challenge: challenge),
    );

    return file;
  }
}
