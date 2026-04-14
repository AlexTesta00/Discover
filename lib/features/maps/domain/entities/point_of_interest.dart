import 'package:latlong2/latlong.dart';

class PredefinedPoi {
  final String id;
  final String name;
  final LatLng position;
  final String? imageAsset;
  final String? locationImage;
  final String? subtitle;

  const PredefinedPoi({
    required this.id,
    required this.name,
    required this.position,
    this.imageAsset,
    this.locationImage,
    this.subtitle,
  });
}
