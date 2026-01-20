import 'dart:async';
import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/presentation/state_management/authentication_gate.dart';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/challenge/domain/use_cases/photo_label_service.dart';
import 'package:discover/features/challenge/presentation/widgets/modal_not_completed.dart';
import 'package:discover/features/challenge/presentation/widgets/modal_success_challenge.dart';
import 'package:discover/features/challenge/utils/utils.dart';
import 'package:discover/features/gamification/domain/use_cases/collectible_service.dart';
import 'package:discover/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:discover/utils/domain/use_cases/show_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
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
  final labelService = PhotoLabelService(confidence: 0.6);
  final collRepo = CollectiblesService(Supabase.instance.client);

  // Listener per foto catturate
  bus.stream.where((e) => e is PhotoCapturedEvent).cast<PhotoCapturedEvent>().listen((
    e,
  ) async {
    try {
      // 1) etichetta immagine con MLKit
      final mlLabels = await labelService.labelsFor(e.file);

      debugPrint(
        '📸 [MLKit] Labels trovate per challenge "${e.challenge.title}": $mlLabels',
      );

      // 2) confronta con labels della challenge (campo text[] nel tuo model)
      final chLabels = e.challenge.labels;
      debugPrint('🎯 [Challenge] Labels attese: $chLabels');
      final ok = anyLabelMatches(mlLabels: mlLabels, challengeLabels: chLabels);

      if (!ok) {
        final ctx = navKey.currentContext;
        if (ctx != null) {
          // ignore: use_build_context_synchronously
          await showNotCompletedModal(ctx, challenge: e.challenge);
        }
        return;
      }

      // ✅ valida: procedi con submit (upload + DB), includi le ml labels nei meta
      final submissionId = await repo.submitChallenge(
        challengeId: e.challenge.id,
        photoFile: e.file,
        photoMeta: {
          'ml_labels': mlLabels.toList(),
          'challenge_labels': chLabels,
        },
      );

      // 3) pubblica completata (il tuo altro listener premierà + mostrerà il modale success)
      bus.publish(
        ChallengeCompletedEvent(
          submissionId: submissionId,
          challenge: e.challenge,
        ),
      );
    } catch (err) {
      bus.publish(
        ChallengeCompletionFailedEvent(challenge: e.challenge, error: err),
      );
    }
  });

  // Listener per dialoghi con personaggi
  bus.stream
      .where((e) => e is CharacterArrivedEvent)
      .cast<CharacterArrivedEvent>()
      .listen((event) async {
        try {
          final (submissionId, wasNew) = await repo
              .completeTalkChallengeForCharacter(event.characterId);

          if (!wasNew) return; // già completata → no doppio premio

          // Recupera la challenge per mostrare il modale
          final row = await client
              .from('challenges')
              .select('''
            id, title, description, xp, fenicotteri,
            requires_photo, is_active, character_id,
            characters:character_id (id, name, image_asset, story, lat, lng)
          ''')
              .eq('character_id', event.characterId)
              .eq('requires_photo', false)
              .maybeSingle();

          if (row == null) return;

          final challenge = Challenge.fromMap(row);

          // Premia utente
          await addXpAndBalance(
            xp: challenge.xp,
            balance: challenge.fenicotteri,
          );

          // Mostra modale di successo
          final ctx = navKey.currentContext;
          if (ctx != null) {
            // ignore: use_build_context_synchronously
            await showSuccessChallengeModal(ctx, challenge: challenge);
          }
        } catch (e) {
          debugPrint('Errore completamento challenge RPC: $e');
        }
      });
  // Listener per assegnazione collezionabili
  bus.stream
      .where((e) => e is ChallengeCompletedEvent)
      .cast<ChallengeCompletedEvent>()
      .listen((e) async {
        try {
          // l’evento ha già la challenge completata
          final challenge = e.challenge;

          // Prova ad assegnare il collezionabile del personaggio
          final awarded = await collRepo.awardIfCompleted(
            challenge.characterId,
          );

          if (awarded) {
            // mostra modale “hai sbloccato lo sticker”
            final ctx = navKey.currentContext;
            if (ctx != null) {
              await showSuccessModal(
                // ignore: use_build_context_synchronously
                ctx,
                title: 'Nuovo collezionabile sbloccato! 🎉',
                description:
                    'Hai completato tutte le challenge di '
                    '${challenge.character.name} e ottenuto lo sticker!',
              );
            }
          }
        } catch (err) {
          debugPrint('awardIfCompleted errore: $err');
        }
      });
}

class MyApp extends StatelessWidget {
  final bool hasCompleteOnBoarding;
  const MyApp({super.key, required this.hasCompleteOnBoarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navKey,
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: hasCompleteOnBoarding
          ? const AuthenticationGate()
          : const OnBoardingScreen(),
    );
  }
}
