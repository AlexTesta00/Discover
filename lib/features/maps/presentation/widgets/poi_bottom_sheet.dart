import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:flutter/material.dart';

class PoiBottomSheet extends StatelessWidget {
  final PredefinedPoi poi;
  final VoidCallback onStart;

  const PoiBottomSheet({
    super.key,
    required this.poi,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar/immagine
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondaryContainer,
              ),
              clipBehavior: Clip.antiAlias,
              child: poi.imageAsset != null
                  ? Image.asset(poi.imageAsset!, fit: BoxFit.cover)
                  : Icon(Icons.place, size: 36, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              poi.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Raggiungi'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
