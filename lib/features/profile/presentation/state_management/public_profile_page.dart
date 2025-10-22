import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/user/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:discover/features/gamification/domain/entities/level.dart';
import 'package:discover/features/profile/presentation/pages/profile_page.dart';
import 'package:discover/utils/presentation/pages/error_page.dart';
import 'package:discover/utils/presentation/pages/loading_page.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart'
    show getFriendsCountByEmail, getUserByEmail;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({super.key, required this.email});

  final String email;

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  late Future<User?> _userFuture;
  int _friendsCount = 0;
  List<String> _challengeImages = const [];

  @override
  void initState() {
    super.initState();
    _userFuture = _load();
  }

  Future<User?> _load() async {
    try {
      final u = await getUserByEmail(widget.email);
      _friendsCount = await getFriendsCountByEmail(widget.email);
      final repo = ChallengeRepository(Supabase.instance.client);
      _challengeImages = await repo.getPublicPhotoUrlsByEmail(widget.email);
      return u;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return LoadingPage();
        }
        if (snap.hasError) {
          return ErrorPage(message: 'Errore durante il caricamento: ${snap.error}');
        }
        final user = snap.data;
        if (user == null) {
          return const ErrorPage(message: 'Utente non trovato');
        }

        return RefreshIndicator(
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
            friendsCount: _friendsCount,
            challengeImages: _challengeImages,
            progress: Level.progressToNextLevel(
              user.xp,
              user.nextLevel.xpToReach,
            ),
          ),
        );
      },
    );
  }
}
