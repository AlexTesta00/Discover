import 'package:discover/features/challenge/domain/entities/challenge_submission_item.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengePreviewCard extends StatefulWidget {
  final String email;
  final VoidCallback onOpenChallenges;
  final List<BoxShadow> shadow;

  const ChallengePreviewCard({
    super.key,
    required this.email,
    required this.onOpenChallenges,
    required this.shadow,
  });

  @override
  State<ChallengePreviewCard> createState() => _ChallengePreviewCardState();
}

class _ChallengePreviewCardState extends State<ChallengePreviewCard> {
  late Future<List<ChallengeSubmissionItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ChallengeSubmissionItem>> _load() async {
    final repo = ChallengeRepository(Supabase.instance.client);
    final all = await repo.getSubmissionsForEmail(widget.email);
    return all.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFEF4565);
    const titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1B1B1B),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: widget.shadow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Challenge', style: titleStyle),
          const SizedBox(height: 14),
          FutureBuilder<List<ChallengeSubmissionItem>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 72,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Nessuna sfida completata',
                    style: TextStyle(color: Colors.black45, fontSize: 14),
                  ),
                );
              }
              return Row(
                children: items
                    .map((item) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _ChallengeThumb(item: item),
                        ))
                    .toList(),
              );
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onOpenChallenges,
              style: TextButton.styleFrom(
                foregroundColor: primary,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vedi tutte',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeThumb extends StatelessWidget {
  final ChallengeSubmissionItem item;

  const _ChallengeThumb({required this.item});

  ImageProvider _imageProvider(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    const badgeSize = 26.0;
    const thumbSize = 68.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: thumbSize,
          height: thumbSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFF2F2F2),
            image: item.characterImageAsset.isNotEmpty
                ? DecorationImage(
                    image: _imageProvider(item.characterImageAsset),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: item.characterImageAsset.isEmpty
              ? const Icon(Icons.image_not_supported_outlined, color: Colors.black26)
              : null,
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: const BoxDecoration(
              color: Color(0xFFEF4565),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.requiresPhoto ? Icons.photo_camera : Icons.search_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
