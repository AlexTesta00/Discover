import 'package:discover/features/character/domain/entities/character.dart';
import 'package:flutter/material.dart';

class PhotoChallengePickerDialog extends StatefulWidget {
  const PhotoChallengePickerDialog({super.key, required this.characters});

  final List<Character> characters;

  @override
  State<PhotoChallengePickerDialog> createState() =>
      _PhotoChallengePickerDialogState();
}

class _PhotoChallengePickerDialogState
    extends State<PhotoChallengePickerDialog> {
  Character? _selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scatta una foto'),
      contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: widget.characters.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final character = widget.characters[i];
            final isSelected = _selected?.id == character.id;
            return GestureDetector(
              onTap: () => setState(() => _selected = character),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.07)
                      : Colors.white,
                ),
                child: SizedBox(
                  height: 72,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(11),
                        ),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: _buildImage(character.imageAsset),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                character.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (character.subtitle != null &&
                                  character.subtitle!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    character.subtitle!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Annulla'),
        ),
        TextButton(
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(_selected),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _buildImage(String asset) {
    if (asset.startsWith('http')) {
      return Image.network(asset, fit: BoxFit.cover);
    }
    return Image.asset(asset, fit: BoxFit.cover);
  }
}
