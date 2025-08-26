import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/repository/challenge_store.dart';
import 'package:flutter/material.dart';
import 'check_badge.dart';

class ChallengeCard extends StatefulWidget {
  final Challenge challenge;
  final CompletedStore store;
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.store,
  });

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    widget.store.isDone(widget.challenge.id).then((v) {
      if (mounted) setState(() => _done = v);
    });
  }

  void _toggle() async {
    await widget.store.toggle(widget.challenge.id);
    final v = await widget.store.isDone(widget.challenge.id);
    if (mounted) setState(() => _done = v);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: _toggle,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 14,
              offset: Offset(0, 4),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Row(
          children: [
            // immagine rotonda
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                widget.challenge.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // testo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.challenge.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.challenge.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CheckBadge(isChecked: _done),
          ],
        ),
      ),
    );
  }
}
