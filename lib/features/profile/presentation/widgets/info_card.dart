import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key, 
    required this.title,
    required this.value,
    required this.cardColor,
    required this.shadow,
    this.centerValue = false,
  });

  final String title;
  final String value;
  final Color cardColor;
  final List<BoxShadow> shadow;
  final bool centerValue;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1B1B1B),
        );

    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1B1B1B),
        );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: shadow,
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        crossAxisAlignment:
            centerValue ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 8),
          Align(
            alignment: centerValue ? Alignment.center : Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(value, style: valueStyle),
            ),
          ),
        ],
      ),
    );
  }
}
