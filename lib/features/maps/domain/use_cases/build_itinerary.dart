import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:fpdart/fpdart.dart';
import 'package:latlong2/latlong.dart';

typedef ErrorMessage = String;

Either<ErrorMessage, String> buildItineraryUrl(List<LatLng> points){
  if(points.isEmpty || points.length < 2) {
    return Left("Aggiungi almeno due marker per iniziare l'itinerario");
  }

  final origin = points.first;
  final destination = getFarthestPoint(origin, points);
  String waypoints = "";

  if (points.length > 2) {
    final intermediate = points.sublist(1, points.length - 1);
    waypoints = intermediate
        .map((p) => "${p.latitude},${p.longitude}")
        .join('|');
  }

  final urlBuffer = StringBuffer(
    "https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}");
  
  if (waypoints.isNotEmpty) {
    urlBuffer.write("&waypoints=$waypoints");
  }

  urlBuffer.write(
    "&destination=${destination.latitude},${destination.longitude}&travelmode=walking");
  
  return Right(urlBuffer.toString());
}

LatLng getFarthestPoint(LatLng origin, List<LatLng> points){
  final distance = Distance();
  LatLng farthestPoint = points.first;
  double maxDistance = distance(origin, farthestPoint);
  for (final point in points) {
    final currentDistance = distance(origin, point);
    if (currentDistance > maxDistance) {
      maxDistance = currentDistance;
      farthestPoint = point;
    }
  }
  return farthestPoint;
}

List<PointOfInterest> addPointOfInterest(
  List<PointOfInterest> currentPoints, 
  LatLng position
) => List.unmodifiable([...currentPoints, PointOfInterest(position: position)]);
