import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonChallengesList extends StatelessWidget {
  final int itemCount;
  const SkeletonChallengesList({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SkeletonSectionHeader(),
        ...List.generate(itemCount, (_) => const SkeletonChallengeCard()),
      ],
    );
  }
}

class SkeletonSectionHeader extends StatelessWidget {
  const SkeletonSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Row(
          children: [
            Container(
              height: 24.0,
              width: 180.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const Spacer(),
            Container(
              height: 20.0,
              width: 80.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonChallengeCard extends StatelessWidget {
  const SkeletonChallengeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlight = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
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
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonLine(height: 16.0, width: w * 0.90),
                        const SizedBox(height: 8),
                        _SkeletonLine(height: 16.0, width: w * 0.65),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _SkeletonPill(width: 70),
                            const SizedBox(width: 8),
                            _SkeletonPill(width: 50),
                            const SizedBox(width: 8),
                            _SkeletonPill(width: 90),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 8,
                            width: w * 0.70,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // CTA o badge a sinistra (placeholder)
                        _SkeletonLine(height: 36.0, width: 120),
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
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double height;
  final double width;
  const _SkeletonLine({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _SkeletonPill extends StatelessWidget {
  final double width;
  const _SkeletonPill({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}