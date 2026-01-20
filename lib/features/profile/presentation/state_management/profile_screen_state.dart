import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/gamification/domain/entities/level.dart';
import 'package:discover/features/profile/presentation/pages/profile_page.dart';
import 'package:discover/features/user/domain/entities/user.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:discover/utils/presentation/pages/error_page.dart';
import 'package:discover/utils/presentation/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class ProfileScreenState extends StatefulWidget {
  const ProfileScreenState({super.key});

  @override
  State<ProfileScreenState> createState() => _ProfileScreenStateState();
}

class _ProfileScreenStateState extends State<ProfileScreenState> {
  late Future<Either<String, User>> _userFuture;
  late int friendsCount;
  List<String> _challengeImages = const [];

  @override
  void initState() {
    _userFuture = _load();
    super.initState();
  }

  // --- versione con Either<String, User> ---
  Future<Either<String, User>> _load() async {
    try {
      final email = getUserEmail();
      if (email == null) {
        return left('Email non trovata');
      }

      final repo = ChallengeRepository(Supabase.instance.client);

      final result = await Future.wait([
        getUserAvatar(),
        getUserBackground(),
        getUserXp(),
        getUserBalance(),
        getMyLevel(),
        getNextLevel(),
        repo.getUserChallengePhotoUrls(),
        getFriendsCount()
      ], eagerError: true);

      final userAvatar = (result[0] as String?) ?? 'assets/icons/error.png';
      final userBackground = (result[1] as String?) ?? 'assets/background/error.png';
      final userXp = (result[2] as int?) ?? 0;
      final userBalance = (result[3] as int?) ?? 0;
      final userLevel = (result[4] as Level?) ??
          Level(grade: 0, name: 'Sconosciuto', xpToReach: 0);
      final nextLevel = (result[5] as Level?) ??
          Level(grade: 0, name: 'Sconosciuto', xpToReach: 0);
      _challengeImages = (result[6] as List<String>);
      friendsCount = (result[7] as int);

      final user = User(
        email: email,
        avatarImage: userAvatar,
        backgroundImage: userBackground,
        xp: userXp,
        balance: userBalance,
        level: userLevel,
        nextLevel: nextLevel,
      );

      debugPrint('DEBUG: $_challengeImages');

      return right(user);
    } catch (e) {
      return left('Errore durante il caricamento utente: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Either<String, User>>(
      future: _userFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return LoadingPage();
        }

        if (snap.hasError) {
          return ErrorPage(message: 'Errore imprevisto: ${snap.error}');
        }

        if (!snap.hasData) {
          return ErrorPage(message: 'Nessun dato disponibile');
        }

        return snap.data!.match(
          (err) => Center(
            child: Text(
              'Errore: $err',
              style: const TextStyle(color: Colors.red),
            ),
          ),
          (user) => RefreshIndicator(
            displacement: 56,
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              setState(() {
                _userFuture = _load();
              });
              await _userFuture;
            },
            child: ProfilePage(
              headerImage: user.backgroundImage,
              avatarImage: user.avatarImage,
              username: user.email.split('@').first,
              levelLabel: 'Liv.${user.level.grade} - ${user.level.name}',
              friendsCount: friendsCount,
              challengeImages: _challengeImages,
              progress: Level.progressToNextLevel(
                user.xp,
                user.nextLevel.xpToReach,
              ),
            ),
          ),
        );
      },
    );
  }
}
