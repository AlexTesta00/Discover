import 'package:flutter/material.dart';

class EtaBanner extends StatelessWidget {
  const EtaBanner({
    super.key,
    required this.remainMeters,
    required this.etaSeconds,
    required this.onStop,
    this.visible = true,
  });

  final double remainMeters;
  final double etaSeconds;
  final VoidCallback onStop;
  final bool visible;

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000.0;
      return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatEta(double seconds) {
    if (seconds <= 0) return '0 min';
    final m = (seconds / 60).floor();
    final s = (seconds % 60).round();
    if (m >= 60) {
      final h = (m / 60).floor();
      final mm = m % 60;
      return '${h}h ${mm}m';
    }
    return s > 0 ? '${m}m ${s}s' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.near_me),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Distanza: ${_formatDistance(remainMeters)} · Tempo: ${_formatEta(etaSeconds)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onStop,
                child: const Text('Stop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
