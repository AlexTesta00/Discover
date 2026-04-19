import 'dart:async';

import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/presentation/pages/challenge_history_page.dart';
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

class ProfileScreenState extends StatefulWidget {
  final VoidCallback? onLogout;
  const ProfileScreenState({super.key, this.onLogout});

  @override
  State<ProfileScreenState> createState() => _ProfileScreenStateState();
}

class _ProfileScreenStateState extends State<ProfileScreenState> {
  late Future<Either<String, User>> _userFuture;
  late int friendsCount;
  StreamSubscription? _busSub;

  @override
  void initState() {
    super.initState();
    _userFuture = _load();
    _busSub = ChallengeEventBus.I.stream.listen((event) {
      if (event is ChallengeCompletedEvent && mounted) {
        setState(() {
          _userFuture = _load();
        });
      }
    });
  }

  @override
  void dispose() {
    _busSub?.cancel();
    super.dispose();
  }

  Future<Either<String, User>> _load() async {
    try {
      final email = getUserEmail();
      if (email == null) {
        return left('Email non trovata');
      }

      final result = await Future.wait([
        getUserAvatar(),
        getUserBackground(),
        getUserXp(),
        getUserBalance(),
        getMyLevel(),
        getNextLevel(),
        getFriendsCount(),
        getUserUsername(),
      ], eagerError: true);

      final userAvatar = (result[0] as String?) ?? 'assets/icons/error.png';
      final userBackground = (result[1] as String?) ?? 'assets/background/error.png';
      final userXp = (result[2] as int?) ?? 0;
      final userBalance = (result[3] as int?) ?? 0;
      final userLevel = (result[4] as Level?) ?? Level(grade: 0, name: 'Sconosciuto', xpToReach: 0);
      final nextLevel = (result[5] as Level?) ?? Level(grade: 0, name: 'Sconosciuto', xpToReach: 0);
      friendsCount = (result[6] as int);
      final username = (result[7] as String?) ?? email.split('@').first;

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

      return right(user);
    } catch (e) {
      return left('Errore durante il caricamento utente: $e');
    }
  }

  Future<void> _showEditUsernameDialog(String currentUsername) async {
    final controller = TextEditingController(text: currentUsername);

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

    final nav = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.of(context);

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
              email: user.email,
              headerImage: user.backgroundImage,
              avatarImage: user.avatarImage,
              username: user.username,
              levelLabel: 'Liv.${user.level.grade} - ${user.level.name}',
              friendsCount: friendsCount,
              progress: Level.progressToNextLevel(user.xp, user.nextLevel.xpToReach),
              onLogout: widget.onLogout,
              onEditUsername: () => _showEditUsernameDialog(user.username),
              onOpenChallenges: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => ChallengeHistoryPage(
                      email: user.email,
                      isOwnProfile: true,
                      username: user.username,
                    ),
                  ),
                );
              },
              onOpenFriends: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(builder: (_) => const FriendshipGate()),
                );
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
