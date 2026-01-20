import 'package:discover/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class ChallengeGrid extends StatelessWidget {
  const ChallengeGrid({
    super.key,
    required this.images,
    this.height = 300, // altezza della card che contiene lo scroll
  });

  final List<String> images;
  final double height;

  @override
  Widget build(BuildContext context) {
    final shadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 8),
      ),
    ];

    if (images.isEmpty) {
      return InfoCard(
        title: 'Challenge',
        value: 'Nessuna challenge',
        cardColor: Colors.white,
        shadow: shadow,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo come nello screenshot
          Text(
            'Challenge',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),

          // area scrollabile con la grid
          SizedBox(
            height: height,
            child: Scrollbar(
              thumbVisibility: true,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,        // due colonne come in foto
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,   // tile più alti (stile ritratto)
                ),
                itemBuilder: (context, index) {
                  final src = images[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      src,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, w, p) =>
                          p == null ? w : const ColoredBox(color: Color(0xFFF2F2F2)),
                      errorBuilder: (c, e, s) => const ColoredBox(
                        color: Color(0xFFF2F2F2),
                        child: Center(child: Icon(Icons.broken_image_outlined)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
