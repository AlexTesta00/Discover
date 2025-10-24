import 'package:flutter/material.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';

class PoiArrivalSheet extends StatelessWidget {
  final PredefinedPoi poi;
  final VoidCallback onReadStory;

  const PoiArrivalSheet({
    super.key,
    required this.poi,
    required this.onReadStory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar;
    final img = poi.imageAsset;
    if (img != null && img.isNotEmpty) {
      if (img.startsWith('http')) {
        avatar = ClipOval(
          child: Image.network(img, width: 96, height: 96, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 48, color: theme.primaryColor),
          ),
        );
      } else {
        avatar = ClipOval(
          child: Image.asset(img, width: 96, height: 96, fit: BoxFit.cover),
        );
      }
    } else {
      avatar = CircleAvatar(
        radius: 48,
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Icon(Icons.place, size: 42, color: theme.primaryColor),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            avatar,
            const SizedBox(height: 16),
            Text(
              poi.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              "Devi completare tutte le mie challenge se vuoi ricevere il mio trofeo",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onReadStory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Leggi la storia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
