import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonArticleCard extends StatelessWidget {
  const SkeletonArticleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonna testo (come la ArticleCard)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Larghezze variabili per simulare righe di testo
                  final w = constraints.maxWidth;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Block(height: 16, width: w * 0.95),
                      const SizedBox(height: 8),
                      _Block(height: 16, width: w * 0.70),
                      const SizedBox(height: 12),
                      _Block(height: 12, width: w * 0.35),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 72,
                height: 72,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double height;
  final double width;
  const _Block({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}