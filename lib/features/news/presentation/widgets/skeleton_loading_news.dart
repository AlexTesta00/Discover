import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoadingNews extends StatelessWidget {
  final int itemCount;

  const SkeletonLoadingNews({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (_, __) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Immagine placeholder
                Container(
                  width: 100,
                  height: 80,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                // Testo placeholder
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 150, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 100, color: Colors.white),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}