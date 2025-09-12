import 'package:discover/features/news/presentation/widgets/skeleton_article_card.dart';
import 'package:flutter/material.dart';

class SkeletonLoadingNews extends StatelessWidget {
  final int itemCount;
  const SkeletonLoadingNews({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (_, __) => const SkeletonArticleCard(),
    );
  }
}