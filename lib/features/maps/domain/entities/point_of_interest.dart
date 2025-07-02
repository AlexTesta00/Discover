import 'package:latlong2/latlong.dart';

class PointOfInterest {

  final String? title;
  final String? description;
  final String? imageUrl;
  final LatLng position;

  PointOfInterest({
    this.title,
    this.description,
    this.imageUrl,
    required this.position,
  });
}