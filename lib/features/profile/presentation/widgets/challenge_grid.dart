import 'package:discover/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

class ChallengeGrid extends StatelessWidget {
  const ChallengeGrid({super.key, required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final shadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
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
    } else {
      return Container(); //TODO: load image from challenge list
    }
    // return GridView.builder(
    //   shrinkWrap: true,
    //   physics: const NeverScrollableScrollPhysics(),
    //   itemCount: images.length,
    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //     crossAxisCount: 2, // 2 colonne fisse
    //     mainAxisSpacing: 12,
    //     crossAxisSpacing: 12,
    //     childAspectRatio: 1.2,
    //   ),
    //   itemBuilder: (context, index) {
    //     final src = images[index];
    //     return ClipRRect(
    //       borderRadius: BorderRadius.circular(14),
    //       child: _buildImage(src, fit: BoxFit.cover),
    //     );
    //   },
    // );
  }
}
