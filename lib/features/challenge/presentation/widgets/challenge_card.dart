import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/challenge/domain/use_cases/photo_capture_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeCard extends StatefulWidget {
  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.completed,
  });

  final Challenge challenge;
  final bool completed;

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final ch = widget.challenge.character;
    final imageProvider = _imageProviderFrom(ch.imageAsset);
    final bool isDisabled = widget.completed || _busy;

    return MouseRegion(
      cursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: GestureDetector(
          onTap: _onTap,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isDisabled ? 0.5 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    offset: Offset(0, 4),
                    blurRadius: 12,
                  )
                ],
              ),
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFF34E6C),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: imageProvider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ch.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.challenge.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.completed)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _imageProviderFrom(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    return AssetImage(path);
  }

  Future<void> _onTap() async {
    final challenge = widget.challenge;

    // se non richiede foto, niente azione (puoi aprire dettaglio se vuoi)
    if (!challenge.requiresPhoto) {
      return;
    }

    setState(() => _busy = true);
    try {
      final client = Supabase.instance.client;
      final repo = ChallengeRepository(client);
      final captureService = PhotoCaptureService(repo);

      await captureService.captureForChallenge(challenge);
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
