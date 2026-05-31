import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:latlong2/latlong.dart';

class Character {
  final String id;
  final String name;
  final String imageAsset;
  final String story;
  final double lat;
  final double lng;
  final String? locationImage;
  final String? subtitle;

  const Character({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.story,
    required this.lat,
    required this.lng,
    this.locationImage,
    this.subtitle,
  });

  LatLng get position => LatLng(lat, lng);

  factory Character.fromMap(Map<String, dynamic> m) => Character(
    id: m['id'] as String,
    name: m['name'] as String,
    imageAsset: m['image_asset'] as String,
    story: m['story'] as String,
    lat: (m['lat'] as num).toDouble(),
    lng: (m['lng'] as num).toDouble(),
    locationImage: m['location_image'] as String?,
    subtitle: m['subtitle'] as String?,
  );
}

extension CharacterToPoi on Character {
  PredefinedPoi toPoi() => PredefinedPoi(
    id: id,
    name: name,
    position: position,
    imageAsset: imageAsset,
    locationImage: locationImage,
    subtitle: subtitle,
  );
}
