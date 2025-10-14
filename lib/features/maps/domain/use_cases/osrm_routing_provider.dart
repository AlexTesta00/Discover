import 'dart:convert';
import 'package:discover/features/maps/domain/entities/routing_model.dart';
import 'package:discover/features/maps/domain/use_cases/routing_provider.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OSRMRoutingProvider implements RoutingProvider {
  final String baseUrl;

  OSRMRoutingProvider({this.baseUrl = 'https://router.project-osrm.org'});

  @override
  Future<RouteResult> route({
    required RouteProfile profile,
    required List<LatLng> waypoints,
  }) async {
    if (waypoints.length < 2) {
      throw ArgumentError('Minimo 2 waypoints');
    }

    final profileStr = switch (profile) {
      RouteProfile.foot => 'walking',
      RouteProfile.bike => 'cycling',
    };

    //Componiamo il percorso in segmenti [i -> i+1] e uniamo.
    List<LatLng> fullGeom = [];
    double totalDist = 0, totalDur = 0;

    for (int i = 0; i < waypoints.length - 1; i++) {
      final seg = [waypoints[i], waypoints[i + 1]];
      final coords = seg.map((p) => '${p.longitude},${p.latitude}').join(';');
      final uri = Uri.parse(
        '$baseUrl/route/v1/$profileStr/$coords'
        '?overview=full&geometries=geojson&steps=false&annotations=distance,duration&alternatives=false',
      );

      final res = await http.get(uri);
      if (res.statusCode != 200) {
        throw Exception('OSRM ${res.statusCode}: ${res.body}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = json['routes'] as List<dynamic>?;
      if (routes == null || routes.isEmpty) {
        throw Exception('Nessun percorso OSRM');
      }
      final r = routes.first as Map<String, dynamic>;
      final geom = (r['geometry']?['coordinates'] as List).map<LatLng>((c) {
        final lat = (c[1] as num).toDouble();
        final lon = (c[0] as num).toDouble();
        return LatLng(lat, lon);
      }).toList();

      final distance = (r['distance'] as num?)?.toDouble() ?? 0;
      final duration = (r['duration'] as num?)?.toDouble() ?? 0;

      if (i == 0) {
        fullGeom.addAll(geom);
      } else {
        // evita duplicare il nodo di giunzione
        fullGeom.addAll(geom.skip(1));
      }
      totalDist += distance;
      totalDur += duration;
    }

    return RouteResult(
      geometry: fullGeom,
      distanceMeters: totalDist,
      durationSeconds: totalDur,
    );
  }
}
