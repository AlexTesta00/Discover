import 'dart:async';
import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/presentation/pages/authentication_page.dart';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('it_IT', null);
  await Supabase.initialize(
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    url: dotenv.env['SUPABASE_URL'] ?? '',
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  final hasCompleteOnBoarding =
      sharedPreferences.getBool('onBoardingComplete') ?? false;

  _initEventStream();

  runApp(MyApp(hasCompleteOnBoarding: hasCompleteOnBoarding));
}

void _initEventStream() {
  final bus = ChallengeEventBus.I;
  final client = Supabase.instance.client;
  final repo = ChallengeRepository(client);

  bus.stream
      .where((e) => e is PhotoCapturedEvent)
      .cast<PhotoCapturedEvent>()
      .listen((event) async {
    try {
      final submissionId = await repo.submitChallenge(
        challengeId: event.challenge.id,
        photoFile: event.file,
        photoMeta: {
          'source': 'camera',
          'character_id': event.challenge.characterId,
          'challenge_title': event.challenge.title,
        },
      );

      // Notifica "completata"
      bus.publish(ChallengeCompletedEvent(
        submissionId: submissionId,
        challenge: event.challenge,
      ));
    } catch (e) {
      bus.publish(ChallengeCompletionFailedEvent(
        challenge: event.challenge,
        error: e,
      ));
    }
  });

  // === Subscriber DIALOGHI (non-foto) ===
  bus.stream
      .where((e) => e is DialogueChallengeTappedEvent)
      .cast<DialogueChallengeTappedEvent>()
      .listen((event) async {
    // Qui metti la logica “dialogo” (es. segnare come iniziata,
    // creare un draft, mostrare un prompt, ecc.). Per ora è uno stub.
    // Esempio futuro:
    // await repo.startDialogue(challengeId: event.challenge.id);

    // Log/placeholder:
    // print('DialogueChallengeTappedEvent: ${event.challenge.id}');
  });
}

class MyApp extends StatelessWidget {
  final bool hasCompleteOnBoarding;
  const MyApp({super.key, required this.hasCompleteOnBoarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: hasCompleteOnBoarding
          ? const AuthenticationPage()
          : const OnBoardingScreen(),
    );
  }
}