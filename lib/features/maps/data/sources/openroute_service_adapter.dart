import 'package:discover/features/maps/domain/entities/route_service_port.dart';
import 'package:discover/features/maps/domain/use_cases/route_service.dart' as legacy;
import 'package:latlong2/latlong.dart';

class OpenRouteServiceAdapter implements RouteServicePort {
  @override
  Future<List<LatLng>> getRoute(List<LatLng> points, {String profile = 'foot-walking'}) {
    return legacy.RouteService.getRoute(points, profile: profile);
  }
}