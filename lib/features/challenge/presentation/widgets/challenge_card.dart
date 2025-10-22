import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.completed,
  });

  final Challenge challenge;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final ch = challenge.character;
    final imageProvider = _imageProviderFrom(ch.imageAsset);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            offset: Offset(0, 4),
            blurRadius: 12,
          )
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFF34E6C),
            child: CircleAvatar(
              radius: 24,
              backgroundImage: imageProvider,
              onBackgroundImageError: (_, __) {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ch.name, // <- nome del character
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.title, // <- titolo della challenge
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (completed)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF24C28A),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  ImageProvider _imageProviderFrom(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return AssetImage(path);
  }
}
