import 'package:discover/features/profile/presentation/widgets/challenge_grid.dart';
import 'package:discover/features/profile/presentation/widgets/header.dart';
import 'package:discover/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.username,
    required this.friendsCount,
    required this.levelLabel,
    required this.headerImage,
    required this.avatarImage,
    required this.challengeImages, //= const <String>[],
    required this.progress,
  });

  final String headerImage;
  final String avatarImage;
  final String username;
  final int friendsCount;
  final String levelLabel;
  final List<String> challengeImages;
  final double progress;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F7F3);
    final textColor = const Color(0xFF1B1B1B);
    final cardColor = Colors.white;
    final shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Header(
              headerImage: headerImage,
              avatarImage: avatarImage,
              shadow: shadow,
              progress: progress,
              ringColor: Theme.of(context).colorScheme.primary,
              ringThickness: 5.0,
              ringSize: 128.0,
            ),
            const SizedBox(height: 42),

            // Username
            Text(
              username,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Card "Amici"
            InfoCard(
              title: 'Amici',
              value: '$friendsCount',
              cardColor: cardColor,
              shadow: shadow,
            ),
            const SizedBox(height: 32),

            // Card "Livello"
            InfoCard(
              title: 'Livello',
              value: levelLabel,
              cardColor: cardColor,
              shadow: shadow,
            ),
            const SizedBox(height: 32),

            ChallengeGrid(images: challengeImages),
          ],
        ),
      ),
    );
  }
}
