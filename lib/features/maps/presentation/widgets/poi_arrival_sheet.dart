import 'package:flutter/material.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';

class PoiArrivalSheet extends StatelessWidget {
  final PredefinedPoi poi;
  final VoidCallback onReadStory;
  final VoidCallback? onViewAr; // 👈 AGGIUNTO

  const PoiArrivalSheet({
    super.key,
    required this.poi,
    required this.onReadStory,
    this.onViewAr, // 👈 AGGIUNTO
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar;
    final img = poi.imageAsset;

    // Avatar del personaggio
    if (img != null && img.isNotEmpty) {
      if (img.startsWith('http')) {
        avatar = ClipOval(
          child: Image.network(
            img,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Icon(
              Icons.image_not_supported,
              size: 48,
              color: theme.primaryColor,
            ),
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

            // Nome del personaggio
            Text(
              poi.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Piccola descrizione
            Text(
              'Devi completare tutte le mie challenge se vuoi ricevere il mio trofeo',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Bottone: Leggi la storia
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onReadStory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Leggi la storia'),
              ),
            ),

            const SizedBox(height: 12),

            // Bottone AR (mostrato solo se presente la callback)
            if (onViewAr != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onViewAr,
                  icon: Icon(
                    Icons.view_in_ar,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(
                    'Vedi in AR',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Theme.of(context).primaryColor, // colore bordo
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
