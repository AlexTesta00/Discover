import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Carica un file GeoJSON dall'asset bundle e restituisce
/// una lista di [Polygon] compatibili con flutter_map.
///
/// Supporta geometrie di tipo Polygon e MultiPolygon.
/// Le coordinate GeoJSON sono in formato [lon, lat] e vengono
/// convertite in [LatLng(lat, lon)].
Future<List<Polygon>> loadGeoJsonPolygons(
  String assetPath, {
  Color fillColor = const Color(0x2EE91E8C),
  Color borderColor = const Color(0xBFE91E8C),
  double borderWidth = 2.0,
}) async {
  final jsonStr = await rootBundle.loadString(assetPath);
  final geoJson = json.decode(jsonStr) as Map<String, dynamic>;

  final polygons = <Polygon>[];

  final features = geoJson['features'] as List<dynamic>? ?? [];
  for (final feature in features) {
    final geometry = (feature as Map<String, dynamic>)['geometry'] as Map<String, dynamic>?;
    if (geometry == null) continue;

    final type = geometry['type'] as String;
    final List<List<List<List<double>>>> multiCoords;

    if (type == 'Polygon') {
      multiCoords = [_parsePolygonCoords(geometry['coordinates'] as List)];
    } else if (type == 'MultiPolygon') {
      multiCoords = (geometry['coordinates'] as List)
          .map((p) => _parsePolygonCoords(p as List))
          .toList();
    } else {
      continue;
    }

    for (final polyCoords in multiCoords) {
      if (polyCoords.isEmpty) continue;

      final outer = polyCoords[0].map((c) => LatLng(c[1], c[0])).toList();
      final holes = polyCoords.length > 1
          ? polyCoords
              .skip(1)
              .map((ring) => ring.map((c) => LatLng(c[1], c[0])).toList())
              .toList()
          : <List<LatLng>>[];

      polygons.add(Polygon(
        points: outer,
        holePointsList: holes,
        color: fillColor,
        borderColor: borderColor,
        borderStrokeWidth: borderWidth,
      ));
    }
  }

  return polygons;
}

List<List<List<double>>> _parsePolygonCoords(List coords) =>
    coords
        .map((ring) => (ring as List)
            .map((pt) => (pt as List).map((v) => (v as num).toDouble()).toList())
            .toList())
        .toList();
