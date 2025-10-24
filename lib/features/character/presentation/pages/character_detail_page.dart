import 'package:discover/features/character/domain/entities/character.dart';
import 'package:flutter/material.dart';

class CharacterDetailPage extends StatelessWidget {
  final Character character;

  const CharacterDetailPage({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget headerImage;
    final img = character.imageAsset;
    if (img != null && img.isNotEmpty) {
      if (img.startsWith('http')) {
        headerImage = Image.network(
          img,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: Icon(Icons.image_not_supported, size: 48, color: theme.primaryColor),
          ),
        );
      } else {
        headerImage = Image.asset(img, fit: BoxFit.cover);
      }
    } else {
      headerImage = Container(
        color: Colors.black12,
        alignment: Alignment.center,
        child: Icon(Icons.image, size: 48, color: theme.primaryColor),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER IMAGE 16:9 circa
            AspectRatio(
              aspectRatio: 16 / 9,
              child: headerImage,
            ),

            // CONTENUTO
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      character.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      character.story ??
                          "Nessuna descrizione disponibile al momento.",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB indietro (come nello screenshot)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
