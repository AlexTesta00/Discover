import 'package:flutter/material.dart';

class MapControls extends StatelessWidget {
  final VoidCallback onBuildRouteFromPoints;
  final VoidCallback onClearAll;

  const MapControls({
    super.key,
    required this.onBuildRouteFromPoints,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          heroTag: 'route',
          onPressed: onBuildRouteFromPoints,
          icon: const Icon(Icons.alt_route),
          label: const Text('Percorso'),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'clear',
          onPressed: onClearAll,
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Pulisci'),
          backgroundColor: Colors.redAccent,
        ),
      ],
    );
  }
}
