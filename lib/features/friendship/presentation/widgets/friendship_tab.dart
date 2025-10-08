import 'package:discover/features/profile/presentation/state_management/public_profile_page.dart';
import 'package:discover/features/user/domain/entity/user.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:discover/utils/domain/use_cases/show_modal.dart';
import 'package:flutter/material.dart';
import 'package:discover/features/friendship/presentation/widgets/components.dart';

class FriendshipsTab extends StatelessWidget {
  const FriendshipsTab({
    super.key,
    required this.friends,
    required this.onRefresh,
  });

  final List<User> friends;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (friends.isEmpty) {
      return const Center(child: Text('Nessuna amicizia'));
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: friends.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final u = friends[i];
          return UserTile(
            avatarPath: u.avatarImage,
            title: _usernameFromEmail(u.email),
            subtitle: 'Liv.${u.level.grade} ${u.level.name}',
            onTap: () => _showFriendBottomSheet(ctx, u),
          );
        },
      ),
    );
  }

  static String _usernameFromEmail(String email) {
    final idx = email.indexOf('@');
    return idx == -1 ? email : email.substring(0, idx);
  }

  void _showFriendBottomSheet(BuildContext parentContext, User user) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: false,
      backgroundColor: const Color(0xFFF9F7F3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;
        final primary = Theme.of(sheetContext).colorScheme.primary;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // maniglia
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              AvatarCircle(imagePath: user.avatarImage, size: 84),
              const SizedBox(height: 12),
              Text(
                _usernameFromEmail(user.email),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1B1B1B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Liv.${user.level.grade}. ${user.level.name}',
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF7B7B7B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 🔹 Visualizza Profilo (primario)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: primary,
                  ),
                  onPressed: () async {
                    Navigator.of(sheetContext).pop(); // chiudi modale
                    Navigator.of(parentContext).push(
                      MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(email: user.email),
                      ),
                    );
                  },
                  child: const Text('Visualizza Profilo'),
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: Color(0xFFE53935)),
                    foregroundColor: const Color(0xFFE53935),
                  ),
                  onPressed: () async {
                    Navigator.of(sheetContext).pop(); // chiudi modale
                    final confirm = await _confirmRemoveDialog(
                      parentContext,
                      user,
                    );
                    if (confirm != true) return;

                    try {
                      await removeFriend(user.email);
                      await showSuccessModal(
                        parentContext,
                        title: 'Congratulazioni',
                        description:
                            'Hai rimosso ${_usernameFromEmail(user.email)} dai tuoi amici.',
                      );
                      await onRefresh(); // ricarica lista
                    } catch (e) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('Errore durante la rimozione: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Rimuovi amico'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _confirmRemoveDialog(BuildContext context, User user) {
    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Rimuovere amico?'),
          content: Text(
            'Vuoi rimuovere ${_usernameFromEmail(user.email)} dai tuoi amici?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogCtx).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Rimuovi'),
            ),
          ],
        );
      },
    );
  }
}
