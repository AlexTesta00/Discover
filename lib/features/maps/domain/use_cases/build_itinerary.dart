import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:latlong2/latlong.dart';

List<PointOfInterest> addPointOfInterest(
  List<PointOfInterest> currentPoints, 
  LatLng position
) => List.unmodifiable([...currentPoints, PointOfInterest(position: position)]);
