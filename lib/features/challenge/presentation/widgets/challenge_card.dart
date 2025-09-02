import 'dart:io';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/repository/challenge_store.dart';
import 'package:discover/features/challenge/domain/use_case/challenge_validator.dart';
import 'package:discover/features/challenge/domain/use_case/supabase_storage.dart';
import 'package:discover/features/challenge/presentation/widgets/error_modal.dart';
import 'package:discover/features/challenge/presentation/widgets/modal_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'check_badge.dart';
import 'package:discover/core/app_service.dart';
import 'package:discover/features/gamification/utils.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';

class ChallengeCard extends StatefulWidget {
  final Challenge challenge;
  final CompletedStore store;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.store,
  });

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard> {
  bool _done = false;
  bool _loading = false;

  final _picker = ImagePicker();
  final _uploader = SupabaseStorageService();

  @override
  void initState() {
    super.initState();
    widget.store.isDone(widget.challenge.id).then((v) {
      if (mounted) setState(() => _done = v);
    });
  }

  Future<void> _handleTapToCapture() async {
    if (_loading || _done) return;
    setState(() => _loading = true);

    try {
      // 1) Scatta/Seleziona
      final XFile? shot = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 92,
      );
      if (shot == null) return;

      final file = File(shot.path);

      // 2) Validazione immagine (ML Kit)
      final validator = ChallengeValidator();
      final res = await validator.validate(widget.challenge, file);

      if (!res.passed) {
        // Mostra breve feedback con le top etichette viste
        final top = res.scores.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final hint = top.take(3).map((e) => '${e.key} ${(e.value * 100).toStringAsFixed(0)}%').join(', ');

        if (mounted) {
          await showDialog(
            context: context,
            builder: (_) => ErrorModal(
              message: 'Foto non valida per "${widget.challenge.title}".\n'
                      'Ho rilevato: $hint',
            ),
          );
        }
        return;
      }

      // 3) Premiazione + upload + setDone
      final email = getUserEmail();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final filename = '${widget.challenge.id}_$email$ts.jpg';

      await _uploader.uploadChallengePhoto(
        file: file,
        email: email ?? 'unknown',
        filename: filename,
      );

      await giveXp(service: AppServices.userService,email: email, xp: widget.challenge.xp, context: context);
      await giveFlamingo(service: AppServices.userService, email: email, qty: widget.challenge.flamingo, context: context);

      await widget.store.setDone(widget.challenge.id, true);

      if (!mounted) return;
      setState(() => _done = true);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ModalCard(
          xp: widget.challenge.xp,
          flamingo: widget.challenge.flamingo,
        ),
      );
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => ErrorModal(message: e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _loading ? 0.6 : 1,
      child: InkWell(
        onTap: _done ? null : _handleTapToCapture,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                blurRadius: 14,
                offset: Offset(0, 4),
                color: Color(0x14000000),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.network(
                  widget.challenge.image,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 40),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.challenge.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.challenge.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ),
                    if (_loading) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Caricamento in corso...'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CheckBadge(isChecked: _done),
            ],
          ),
        ),
      ),
    );
  }
}