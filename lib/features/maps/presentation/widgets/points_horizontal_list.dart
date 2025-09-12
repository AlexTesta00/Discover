import 'package:flutter/material.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/presentation/widgets/point_card.dart';

class PointsHorizontalList extends StatelessWidget {
  final List<PointOfInterest> points;
  final List<PointOfInterest> selected;
  final bool absorb;
  final void Function(PointOfInterest point, bool checked) onToggle;
  final void Function(PointOfInterest point) onFocus;

  const PointsHorizontalList({
    super.key,
    required this.points,
    required this.selected,
    required this.absorb,
    required this.onToggle,
    required this.onFocus,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: points.length,
      itemBuilder: (context, index) {
        final point = points[index];
        final isSelected = selected.contains(point);
        return AbsorbPointer(
          absorbing: absorb,
          child: Opacity(
            opacity: absorb ? 0.4 : 1.0,
            child: PointCard(
              point: point,
              selected: isSelected,
              onSelected: (checked) => onToggle(point, checked ?? false),
            ),
          ),
        );
      },
    );
  }
}
