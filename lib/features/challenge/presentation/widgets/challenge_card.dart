import 'dart:io';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/repository/challenge_store.dart';
import 'package:discover/features/challenge/domain/use_case/supabase_storage.dart';
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
      // 1) Apri fotocamera
      final XFile? shot = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );
      if (shot == null) return; // utente ha annullato

      // 2) Dati utente
      final email = getUserEmail() ?? "anonimo";

      final ts = DateTime.now().millisecondsSinceEpoch;
      final filename = '${widget.challenge.id}_${email}_$ts.jpg';

      await _uploader.uploadChallengePhoto(
        file: File(shot.path),
        email: email,
        filename: filename,
      );

      await giveXp(
        service: AppServices.userService,
        email: email,
        xp: widget.challenge.xp,
        context: context,
      );

      await giveFlamingo(
        service: AppServices.userService,
        email: email,
        qty: widget.challenge.flamingo,
        context: context,
      );

      // 5) Segna completata
      await widget.store.setDone(widget.challenge.id, true);
      if (mounted) {
      setState(() => _done = true);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => ModalCard(
          xp: widget.challenge.xp,
          flamingo: widget.challenge.flamingo,
        ),
      );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
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
                child: Image.asset(
                  widget.challenge.image,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
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