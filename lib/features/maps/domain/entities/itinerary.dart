import 'package:flutter/material.dart';

enum ItineraryCategory { stazioni, parcoPerTutti, bici, birdwatching }

class ItineraryGroup {
  final ItineraryCategory category;
  final String label;
  final Color color;
  final IconData icon;
  final List<String> assetPaths;

  const ItineraryGroup({
    required this.category,
    required this.label,
    required this.color,
    required this.icon,
    required this.assetPaths,
  });
}
