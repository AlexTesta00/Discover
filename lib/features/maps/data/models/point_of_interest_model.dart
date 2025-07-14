import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:latlong2/latlong.dart';

class PointOfInterestModel {
  final String? title;
  final String? description;
  final String? imageUrl;
  final double latitude;
  final double longitude;

  PointOfInterestModel({
    this.title,
    this.description,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  factory PointOfInterestModel.fromJson(Map<String, dynamic> json) {
    return PointOfInterestModel(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  PointOfInterest toEntity() => PointOfInterest(
        title: title,
        description: description,
        imageUrl: imageUrl,
        position: LatLng(latitude, longitude),
      );
}