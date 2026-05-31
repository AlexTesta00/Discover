import 'dart:async';
import 'dart:math';

import 'package:discover/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/point_of_interest.dart';

class OffScreenPoiIndicators extends StatefulWidget {
  final MapController mapController;
  final List<PredefinedPoi> pois;
  final LatLng? userLatLng;
  final void Function(PredefinedPoi) onTap;

  const OffScreenPoiIndicators({
    super.key,
    required this.mapController,
    required this.pois,
    required this.onTap,
    this.userLatLng,
  });

  @override
  State<OffScreenPoiIndicators> createState() => _OffScreenPoiIndicatorsState();
}

class _OffScreenPoiIndicatorsState extends State<OffScreenPoiIndicators> {
  StreamSubscription<MapEvent>? _mapSub;
  static const _dist = Distance();

  @override
  void initState() {
    super.initState();
    _mapSub = widget.mapController.mapEventStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _mapSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        MapCamera camera;
        try {
          camera = widget.mapController.camera;
        } catch (_) {
          return const SizedBox.shrink();
        }

        // Se almeno un POI è visibile, non mostrare nulla
        final anyVisible = widget.pois
            .any((p) => camera.visibleBounds.contains(p.position));
        if (anyVisible) return const SizedBox.shrink();

        final offScreen = widget.pois.toList();

        // Riferimento per il calcolo distanza: posizione utente, altrimenti centro mappa
        final ref = widget.userLatLng ?? camera.center;

        // Trova il POI fuori schermo più vicino al riferimento
        final nearest = offScreen.reduce((a, b) {
          final da = _dist.as(LengthUnit.Meter, ref, a.position);
          final db = _dist.as(LengthUnit.Meter, ref, b.position);
          return da <= db ? a : b;
        });

        const padding = 44.0;
        const indicatorSize = 36.0;

        final pt = camera.getOffsetFromOrigin(nearest.position);
        final cx = w / 2;
        final cy = h / 2;
        final angle = atan2(pt.dy - cy, pt.dx - cx);
        final pos = _edgePosition(cx, cy, angle, w, h, padding);

        return Stack(
          children: [
            Positioned(
              left: pos.dx - indicatorSize / 2,
              top: pos.dy - indicatorSize / 2,
              child: GestureDetector(
                onTap: () => widget.onTap(nearest),
                child: Transform.rotate(
                  angle: angle + pi / 2,
                  child: Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 4,
                          offset: Offset(0, 2),
                          color: Colors.black38,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Offset _edgePosition(
    double cx,
    double cy,
    double angle,
    double w,
    double h,
    double padding,
  ) {
    final cosA = cos(angle);
    final sinA = sin(angle);

    double t = double.infinity;

    if (cosA > 0) t = min(t, (w - padding - cx) / cosA);
    if (cosA < 0) t = min(t, (padding - cx) / cosA);
    if (sinA > 0) t = min(t, (h - padding - cy) / sinA);
    if (sinA < 0) t = min(t, (padding - cy) / sinA);

    return Offset(cx + cosA * t, cy + sinA * t);
  }
}
