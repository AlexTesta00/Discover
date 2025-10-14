import 'package:latlong2/latlong.dart';

enum RouteProfile { foot, bike }

class RouteResult {
  final List<LatLng> geometry;     // polilinea finale unita
  final double distanceMeters;     // somma segmenti
  final double durationSeconds;    // somma segmenti
  const RouteResult({
    required this.geometry,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}
