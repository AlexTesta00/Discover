import 'package:cached_network_image/cached_network_image.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:flutter/material.dart';

class PointCard extends StatelessWidget {
  final PointOfInterest point;
  final bool selected;
  final ValueChanged<bool?> onSelected;

  const PointCard({
    super.key,
    required this.point,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: point.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: point.imageUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.place, size: 50),
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 12,
            right: 12,
            child: Text(
              point.title ?? "Senza titolo",
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Checkbox(
              value: selected,
              activeColor: Colors.pink,
              onChanged: onSelected,
            ),
          ),
        ],
      ),
    );
  }
}
