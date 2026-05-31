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
    const primary = Color(0xFFEF4565);
    const avatarSize = 88.0;
    const avatarOverlap = avatarSize / 2;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header: immagine luogo + avatar personaggio ──
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              _LocationHeader(poi: poi),
              Positioned(
                bottom: -avatarOverlap,
                child: _CharacterAvatar(poi: poi, size: avatarSize),
              ),
            ],
          ),

          // spazio per l'avatar che sporge
          const SizedBox(height: avatarOverlap + 16),

          // ── Testo ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  'Parla con ${poi.name}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Bottone ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Avvia navigazione',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }
}

// ── Immagine di sfondo del luogo ────────────────────────────────────────────

class _LocationHeader extends StatelessWidget {
  final PredefinedPoi poi;
  const _LocationHeader({required this.poi});

  @override
  Widget build(BuildContext context) {
    const height = 180.0;
    final img = poi.locationImage;

    Widget imageWidget;
    if (img != null && img.isNotEmpty) {
      imageWidget = img.startsWith('http')
          ? Image.network(img, width: double.infinity, height: height, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _gradientPlaceholder(height))
          : Image.asset(img, width: double.infinity, height: height, fit: BoxFit.cover);
    } else {
      imageWidget = _gradientPlaceholder(height);
    }

    return Stack(
      children: [
        imageWidget,
        // gradiente in basso per l'avatar
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),
        // gradiente in alto per il testo
        if (poi.subtitle != null && poi.subtitle!.isNotEmpty)
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.45), Colors.transparent],
                ),
              ),
            ),
          ),
        // nome del luogo
        if (poi.subtitle != null && poi.subtitle!.isNotEmpty)
          Positioned(
            top: 16, left: 16, right: 16,
            child: Text(
              poi.subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
              ),
            ),
          ),
      ],
    );
  }

  Widget _gradientPlaceholder(double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEF4565), Color(0xFFFF8FA3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// ── Avatar circolare del personaggio ────────────────────────────────────────

class _CharacterAvatar extends StatelessWidget {
  final PredefinedPoi poi;
  final double size;
  const _CharacterAvatar({required this.poi, required this.size});

  @override
  Widget build(BuildContext context) {
    final img = poi.imageAsset;

    Widget inner;
    if (img != null && img.isNotEmpty) {
      inner = img.startsWith('http')
          ? Image.network(img, fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder())
          : Image.asset(img, fit: BoxFit.cover);
    } else {
      inner = _placeholder();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: inner,
    );
  }

  Widget _placeholder() => const ColoredBox(
        color: Color(0xFFF2F2F2),
        child: Center(child: Icon(Icons.person, size: 36, color: Colors.black26)),
      );
}
