import 'package:discover/features/maps/domain/entities/routing_model.dart';
import 'package:latlong2/latlong.dart';

abstract class RoutingProvider {
  Future<RouteResult> route({
    required RouteProfile profile,
    required List<LatLng> waypoints,
  });
}
