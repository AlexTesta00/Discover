import 'package:discover/features/challenge/domain/entities/challenge_submission_item.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeHistoryPage extends StatefulWidget {
  final String email;
  final bool isOwnProfile;
  final String username;

  const ChallengeHistoryPage({
    super.key,
    required this.email,
    required this.isOwnProfile,
    required this.username,
  });

  @override
  State<ChallengeHistoryPage> createState() => _ChallengeHistoryPageState();
}

class _ChallengeHistoryPageState extends State<ChallengeHistoryPage> {
  late Future<List<ChallengeSubmissionItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ChallengeSubmissionItem>> _load() {
    final repo = ChallengeRepository(Supabase.instance.client);
    return repo.getSubmissionsForEmail(widget.email);
  }

  String _formatDate(DateTime dt) {
    const months = [
      'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F3),
      appBar: AppBar(
        title: const Text('Challenge'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<ChallengeSubmissionItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Errore: ${snap.error}'));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_flags_outlined, size: 48, color: Colors.black26),
                  const SizedBox(height: 12),
                  const Text(
                    'Nessuna sfida completata',
                    style: TextStyle(fontSize: 16, color: Colors.black45),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: primary,
            onRefresh: () async => setState(() { _future = _load(); }),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return _ChallengeCard(
                  item: item,
                  label: widget.isOwnProfile
                      ? 'Hai completato una sfida!'
                      : '${widget.username} ha completato una sfida!',
                  dateLabel: _formatDate(item.completedAt),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final ChallengeSubmissionItem item;
  final String label;
  final String dateLabel;

  const _ChallengeCard({
    required this.item,
    required this.label,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.photoUrl != null)
            Image.network(
              item.photoUrl!,
              width: double.infinity,
              fit: BoxFit.fitWidth,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (_, _, _) => const SizedBox(
                height: 200,
                child: ColoredBox(
                  color: Color(0xFFF2F2F2),
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFEF4565),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.challengeTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
