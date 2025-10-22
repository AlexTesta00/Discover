import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:flutter/material.dart';

Future<void> showSuccessChallengeModal(
  BuildContext parentContext, {
  required Challenge challenge,
}) async {
  final ch = challenge.character;

  ImageProvider _imageProviderFrom(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return AssetImage(path);
  }

  return showDialog<void>(
    context: parentContext,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: const Color(0xFFF34E6C),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: _imageProviderFrom(ch.imageAsset),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Complimenti! 🎉',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Hai completato: ${challenge.title}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatPill(icon: Icons.stars_rounded, label: '+${challenge.xp} XP'),
                  const SizedBox(width: 8),
                  _StatPill(icon: Icons.local_florist, label: '+${challenge.fenicotteri} Fenicotteri'),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(parentContext).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final nav = Navigator.maybeOf(dialogContext, rootNavigator: true);
                    if (nav != null && nav.canPop()) {
                      nav.pop();
                    } else {
                      final parentNav = Navigator.maybeOf(parentContext, rootNavigator: true);
                      parentNav?.maybePop();
                    }
                  },
                  child: const Text('Fantastico!'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
