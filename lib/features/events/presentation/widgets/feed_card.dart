import 'package:discover/features/events/domain/entities/event_item.dart';
import 'package:discover/features/events/utils/time_ago.dart';
import 'package:discover/features/friendship/presentation/widgets/components.dart';
import 'package:discover/features/user/domain/entities/user.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final EventItem item;
  final Future<User?> Function(String email) getUserByEmail;

  const EventCard({
    super.key,
    required this.item,
    required this.getUserByEmail,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👇 avatar con fetch user
          FutureBuilder<User?>(
            future: getUserByEmail(item.ownerEmail),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              final user = snap.data;

              if (user == null || user.avatarImage.isEmpty) {
                return CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                );
              }
              return AvatarCircle(imagePath: user.avatarImage, size: 48);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _prettyName(item.ownerEmail),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgoShort(item.createdAt),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.description, style: textTheme.bodyMedium),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _prettyName(String email) {
    final local = email.split('@').first;
    final parts = local.split(RegExp(r'[._\\-]+')).where((e) => e.isNotEmpty);
    return parts.map((p) => p[0].toUpperCase() + p.substring(1)).join(' ');
  }
}
