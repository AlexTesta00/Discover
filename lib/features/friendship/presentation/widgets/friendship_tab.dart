import 'package:discover/features/friendship/domain/entities/friend_request.dart';
import 'package:discover/features/friendship/domain/use_cases/friend_service.dart';
import 'package:discover/features/profile/presentation/state_management/public_profile_page.dart';
import 'package:discover/features/user/domain/entities/user.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:discover/utils/domain/use_cases/show_modal.dart';
import 'package:flutter/material.dart';
import 'package:discover/features/friendship/presentation/widgets/components.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class FriendshipsTab extends StatelessWidget {
  const FriendshipsTab({
    super.key,
    required this.friends,
    required this.incomingRequests,
    required this.isLoadingIncoming,
    required this.onRefresh,
  });

  final List<User> friends;
  final List<FriendRequest> incomingRequests;
  final bool isLoadingIncoming;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final hasFriends = friends.isNotEmpty;
    final hasRequests = incomingRequests.isNotEmpty;

    if (!hasFriends && !hasRequests && !isLoadingIncoming) {
      return const Center(child: Text('Nessuna amicizia o richiesta'));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // richieste in arrivo
          if (isLoadingIncoming)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (hasRequests) ...[
            const SectionTitle('Richieste di amicizia'),
            const SizedBox(height: 8),
            ...incomingRequests.map((r) => _buildRequestTile(context, r)),
            const SizedBox(height: 24),
          ],

          // lista amici
          const SectionTitle('I tuoi amici'),
          const SizedBox(height: 8),
          if (!hasFriends)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nessuna amicizia'),
            )
          else
            ...friends.map(
              (u) => UserTile(
                avatarPath: u.avatarImage,
                title: _usernameFromEmail(u.email),
                subtitle: 'Liv.${u.level.grade} ${u.level.name}',
                onTap: () => _showFriendBottomSheet(context, u),
              ),
            ),
        ],
      ),
    );
  }

  static String _usernameFromEmail(String email) {
    final idx = email.indexOf('@');
    return idx == -1 ? email : email.substring(0, idx);
  }

  Widget _buildRequestTile(BuildContext context, FriendRequest req) {
    final friendService = FriendService(Supabase.instance.client);

    final otherEmail = req.fromEmail;
    final avatar = req.fromAvatarUrl ?? 'assets/avatar/avatar_9.png';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: UserTile(
        avatarPath: avatar,
        title: _usernameFromEmail(otherEmail),
        subtitle: 'Vuole diventare tuo amico',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Rifiuta',
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () async {
                try {
                  await friendService.rejectRequest(req.id);
                  await onRefresh();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Errore: $e')));
                }
              },
            ),
            IconButton(
              tooltip: 'Accetta',
              icon: Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                try {
                  final ok = await friendService.acceptRequest(req.id);
                  if (ok) {
                    if (!context.mounted) return;
                    await showSuccessModal(
                      context,
                      title: 'Nuova amicizia!',
                      description:
                          'Ora tu e ${_usernameFromEmail(otherEmail)} siete amici.',
                    );
                  }
                  await onRefresh();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Errore: $e')));
                }
              },
            ),
          ],
        ),
      ),
    );
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
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
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
                    Navigator.of(sheetContext).pop();
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
                    Navigator.of(sheetContext).pop();
                    final confirm = await _confirmRemoveDialog(
                      parentContext,
                      user,
                    );
                    if (confirm != true) return;

                    try {
                      await removeFriend(user.email);
                      if (!parentContext.mounted) return;
                      await showSuccessModal(
                        parentContext,
                        title: 'Congratulazioni',
                        description:
                            'Hai rimosso ${_usernameFromEmail(user.email)} dai tuoi amici.',
                      );
                      await onRefresh();
                    } catch (e) {
                      if (!parentContext.mounted) return;
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
