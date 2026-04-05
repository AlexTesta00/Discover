import 'package:discover/features/profile/presentation/widgets/challenge_grid.dart';
import 'package:discover/features/profile/presentation/widgets/header.dart';
import 'package:discover/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback? onOpenFriends;
  final VoidCallback? onOpenFeed;
  final VoidCallback? onLogout;
  final VoidCallback? onEditUsername;

  const ProfilePage({
    super.key,
    required this.username,
    this.onLogout,
    this.onEditUsername,
    required this.friendsCount,
    required this.levelLabel,
    required this.headerImage,
    required this.avatarImage,
    required this.challengeImages,
    required this.progress,
    this.onOpenFriends,
    this.onOpenFeed,
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
        color: Colors.black.withValues(alpha: 0.06),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: (onOpenFriends == null && onOpenFeed == null)
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (onOpenFeed != null)
                  FloatingActionButton.small(
                    heroTag: 'profile_feed_fab',
                    onPressed: onOpenFeed,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const CircleBorder(),
                    elevation: 6,
                    child: const Icon(Icons.notifications_none),
                  ),
                if (onOpenFeed != null && onOpenFriends != null)
                  const SizedBox(height: 12),
                if (onOpenFriends != null)
                  FloatingActionButton.small(
                    heroTag: 'profile_friends_fab',
                    onPressed: onOpenFriends,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const CircleBorder(),
                    elevation: 6,
                    child: const Icon(Icons.group_outlined),
                  ),
              ],
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  username,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (onEditUsername != null)
                  IconButton(
                    onPressed: onEditUsername,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    color: Colors.black45,
                    padding: const EdgeInsets.only(left: 4),
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
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
            const SizedBox(height: 32),
            if (onLogout != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4565),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
