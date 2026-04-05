import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/events/domain/use_cases/event_service.dart';
import 'package:discover/features/events/presentation/pages/feed_gate.dart';
import 'package:discover/features/friendship/presentation/state_management/friendship_gate.dart';
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
  final VoidCallback? onLogout;
  const ProfileScreenState({super.key, this.onLogout});

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
        getFriendsCount(),
        getUserUsername(),
      ], eagerError: true);

      final userAvatar = (result[0] as String?) ?? 'assets/icons/error.png';
      final userBackground = (result[1] as String?) ?? 'assets/background/error.png';
      final userXp = (result[2] as int?) ?? 0;
      final userBalance = (result[3] as int?) ?? 0;
      final userLevel = (result[4] as Level?) ?? Level(grade: 0, name: 'Sconosciuto', xpToReach: 0);
      final nextLevel = (result[5] as Level?) ?? Level(grade: 0, name: 'Sconosciuto', xpToReach: 0);
      _challengeImages = (result[6] as List<String>);
      friendsCount = (result[7] as int);
      final username = (result[8] as String?) ?? email.split('@').first;

      final user = User(
        email: email,
        username: username,
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

  Future<void> _showEditUsernameDialog(String currentUsername) async {
    final controller = TextEditingController(text: currentUsername);

    // 1. Dialog di input — usiamo this.context (sempre valido finché mounted)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifica username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          decoration: const InputDecoration(hintText: 'Nuovo username'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final newUsername = controller.text.trim();
    if (newUsername.isEmpty || newUsername == currentUsername) return;
    if (!mounted) return;

    // 2. Salva riferimenti prima degli await
    final nav = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);

    // 3. Loading dialog bloccante durante la chiamata
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(child: CircularProgressIndicator()),
      ),
    );

    Object? callError;
    try {
      await updateUsername(newUsername);
    } catch (e) {
      callError = e;
    }

    // 4. Chiude sempre il loading, indipendentemente dall'esito
    nav.pop();

    if (!mounted) return;

    if (callError != null) {
      messenger.showSnackBar(SnackBar(
        content: Text('Errore: $callError'),
        backgroundColor: Colors.red,
      ));
    } else {
      setState(() { _userFuture = _load(); });
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
            child: Text('Errore: $err', style: const TextStyle(color: Colors.red)),
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
              username: user.username,
              levelLabel: 'Liv.${user.level.grade} - ${user.level.name}',
              friendsCount: friendsCount,
              challengeImages: _challengeImages,
              progress: Level.progressToNextLevel(user.xp, user.nextLevel.xpToReach),
              onLogout: widget.onLogout,
              onEditUsername: () => _showEditUsernameDialog(user.username),
              onOpenFriends: () {
                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const FriendshipGate()));
              },
              onOpenFeed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => FeedGate(
                      getEventsFeed: ({limit = 50, offset = 0}) => getEventsFeed(limit: limit, offset: offset),
                      getUserByEmail: getUserByEmail,
                      pageSize: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
