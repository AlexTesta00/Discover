import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:flutter/services.dart';
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

TaskEither<ErrorMessage, List<PointOfInterest>> loadPointsFromJson() => 
  TaskEither.tryCatch(
    () async {
      //This links expire in 10 years
      final response = await http.get(Uri.parse(
        'https://xvavdibparbwguuiftrs.supabase.co/storage/v1/object/sign/assets/riccione_points.json?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV8zZjJiMjFmOC0zY2FkLTQ4MzEtODI0Ny0zNjFkNGI4MTI3M2MiLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJhc3NldHMvcmljY2lvbmVfcG9pbnRzLmpzb24iLCJpYXQiOjE3NTE2MjAxOTQsImV4cCI6MjA2Njk4MDE5NH0.FjMR0uPuctCDrZDmK-YuS023lMSDnzAgAWNTCYjz0q4'
      ));
      if(response.statusCode != 200){
        left("Impossibile accedere alla risorsa");
      }
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => PointOfInterest(
        title: json['title'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        position: LatLng(json['latitude'], json['longitude']),
      )).toList();
    }, 
    (error, _) => "Errore durante il caricamento dei punti: $error");