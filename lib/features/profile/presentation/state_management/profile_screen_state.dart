import 'package:discover/features/gamification/domain/entities/level.dart';
import 'package:discover/features/profile/presentation/pages/profile_page.dart';
import 'package:discover/features/user/domain/entity/user.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:flutter/material.dart';

class ProfileScreenState extends StatefulWidget {
  const ProfileScreenState({super.key});

  @override
  State<ProfileScreenState> createState() => _ProfileScreenStateState();
}

class _ProfileScreenStateState extends State<ProfileScreenState> {
  late Future<User> _userFuture;

  @override
  void initState() {
    _userFuture = _load();
    super.initState();
  }

  Future<User> _load() async {
    final email = getUserEmail() ?? 'error';
    final result = await Future.wait([
      getUserAvatar(),
      getUserBackground(),
      getUserXp(),
      getUserBalance(),
      getMyLevel(),
      getNextLevel(),
    ], eagerError: true);

    final userAvatar =
        result[0] as String? ??
        'assets/avatar/avatar_9.png'; //TODO: tech debit error avatar
    final userBackground =
        result[1] as String? ??
        'assets/background/default.png'; //TODO: tech debit error background
    final userXp = result[2] as int? ?? 0; //TODO: tech debit error xp
    final userBalance = result[3] as int? ?? 0; //TODO: tech debit error balance
    final userLevel =
        result[4] as Level? ??
        Level(
          grade: 0,
          name: 'Sconosciuto',
          xpToReach: 0,
        ); //TODO: tech debit error level
    final nextLevel =
        result[5] as Level? ??
        Level(
          grade: 0,
          name: 'Sconosciuto',
          xpToReach: 0,
        ); //TODO: tech debit error gap

    return User(
      email: email,
      avatarImage: userAvatar,
      backgroundImage: userBackground,
      xp: userXp,
      balance: userBalance,
      level: userLevel,
      nextLevel: nextLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(
            child: Text('Error: ${snap.error}'),
          ); //TODO: tech debit loading page
        } else if (snap.hasData) {
          final user = snap.data!;
          return RefreshIndicator(
            displacement: 56,
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              setState(() { _userFuture = _load();});
              await _userFuture;
            },
            child: ProfilePage(
              headerImage: user.backgroundImage,
              avatarImage: user.avatarImage,
              username: user.email.split('@').first,
              levelLabel: 'Liv.${user.level.grade} - ${user.level.name}',
              friendsCount: 0, //TODO: tech debit friends count
              challengeImages: const [], //TODO: tech debit challenges
              progress: Level.progressToNextLevel(user.xp, user.nextLevel.xpToReach),
            ),
          );
        } else {
          return const Center(
            child: Text('Unknown error'),
          ); //TODO: tech debit error page
        }
      },
    );
  }
}
