import 'package:discover/features/profile/presentation/state_management/public_profile_page.dart';
import 'package:discover/features/user/domain/entity/user.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:discover/utils/domain/use_cases/show_modal.dart';
import 'package:flutter/material.dart';
import 'package:discover/features/friendship/presentation/widgets/components.dart';

class InviteFriendsTab extends StatelessWidget {
  const InviteFriendsTab({
    super.key,
    required this.suggestions,
    required this.isLoading,
    required this.isLoadingMore,
    required this.onSearch,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final List<User> suggestions;
  final bool isLoading;
  final bool isLoadingMore;
  final ValueChanged<String> onSearch;
  final Future<void> Function() onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n is ScrollEndNotification &&
              n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
              !isLoading &&
              !isLoadingMore) {
            onLoadMore();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchField(
                  hintText: 'Cerca nuovi amici',
                  onChanged: onSearch,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SectionTitle('Nuovi Amici'),
              ),
            ),
            if (isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (suggestions.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Nessun risultato')),
                ),
              )
            else
              SliverList.builder(
                itemCount: suggestions.length,
                itemBuilder: (ctx, i) {
                  final u = suggestions[i];
                  return UserTile(
                    avatarPath: u.avatarImage,
                    title: _usernameFromEmail(u.email),
                    subtitle: 'Liv.${u.level.grade} ${u.level.name}',
                    onTap: () => _showInviteBottomSheet(context, u),
                  );
                },
              ),
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoadingMore
                    ? const Padding(
                        key: ValueKey('loader'),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  static String _usernameFromEmail(String email) {
    final idx = email.indexOf('@');
    return idx == -1 ? email : email.substring(0, idx);
  }

  void _showInviteBottomSheet(BuildContext parentContext, User user) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: false,
      backgroundColor: const Color(0xFFF9F7F3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final primary = Theme.of(sheetContext).colorScheme.primary;
        final textTheme = Theme.of(sheetContext).textTheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // “maniglia” opzionale per estetica
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
              // Pulsante primario: Aggiungi amico
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
                    Navigator.of(sheetContext).pop(); // Chiudi il bottom sheet
                    try {
                      await addFriend(user.email);
                      await showSuccessModal(
                        sheetContext,
                        title: 'Congratulazioni',
                        description:
                            'Hai aggiunto ${_usernameFromEmail(user.email)} come amico!',
                      );
                      await onRefresh();
                    } catch (e) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('Ops.. qualcosa è andato storto: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Aggiungi come amico'),
                ),
              ),
              const SizedBox(height: 12),
              // Pulsante secondario: Visualizza profilo
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: primary),
                    foregroundColor: primary,
                  ),
                  onPressed: () {
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
            ],
          ),
        );
      },
    );
  }
}
