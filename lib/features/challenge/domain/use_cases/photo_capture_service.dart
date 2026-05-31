import 'dart:io';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoCaptureService {
  PhotoCaptureService(this.repo);
  final ChallengeRepository repo;

  /// Scatta foto, pubblica PhotoCapturedEvent (flusso con validazione ML).
  Future<File?> captureForChallenge(Challenge challenge) async {
    final file = await captureOnly();
    if (file == null) return null;
    ChallengeEventBus.I.publish(PhotoCapturedEvent(file: file, challenge: challenge));
    return file;
  }

  /// Scatta foto senza pubblicare eventi — usato quando il submit viene gestito dal chiamante.
  Future<File?> captureOnly() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (status.isPermanentlyDenied || status.isRestricted) {
        throw Exception('Accesso alla fotocamera negato. Abilitalo dalle Impostazioni di iPhone.');
      }
      throw Exception('Accesso alla fotocamera non concesso.');
    }

    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }
}
