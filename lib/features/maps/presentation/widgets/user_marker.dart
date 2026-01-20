import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Marker userMarker(LatLng p) {
  return Marker(
    point: p,
    width: 40,
    height: 40,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Colors.black26)],
          ),
        ),
      ],
    ),
  );
}
