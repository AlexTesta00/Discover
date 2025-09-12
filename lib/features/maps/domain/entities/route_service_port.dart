import 'package:latlong2/latlong.dart';

abstract class RouteServicePort {
  Future<List<LatLng>> getRoute(List<LatLng> points, {String profile = 'foot-walking'});
}