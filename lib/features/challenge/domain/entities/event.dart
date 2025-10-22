import 'dart:async';
import 'dart:io';

import 'package:discover/features/challenge/domain/entities/challenge.dart';

abstract class ChallengeEvent {
  const ChallengeEvent();
}

class PhotoCapturedEvent extends ChallengeEvent {
  final File file;
  final Challenge challenge;
  const PhotoCapturedEvent({required this.file, required this.challenge});
}

class DialogueChallengeTappedEvent extends ChallengeEvent {
  final Challenge challenge;
  const DialogueChallengeTappedEvent({required this.challenge});
}

class ChallengeEventBus {
  ChallengeEventBus._();
  static final ChallengeEventBus I = ChallengeEventBus._();

  final _controller = StreamController<ChallengeEvent>.broadcast();

  Stream<ChallengeEvent> get stream => _controller.stream;

  void publish(ChallengeEvent event) => _controller.add(event);

  void dispose() {
    _controller.close();
  }
}

class ChallengeCompletedEvent extends ChallengeEvent {
  final String submissionId;
  final Challenge challenge;
  const ChallengeCompletedEvent({required this.submissionId, required this.challenge});
}

class ChallengeCompletionFailedEvent extends ChallengeEvent {
  final Challenge challenge;
  final Object error;
  const ChallengeCompletionFailedEvent({required this.challenge, required this.error});
}
