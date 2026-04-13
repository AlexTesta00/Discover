import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Parco Regionale Delta del Po dell'Emilia-Romagna (OSM Relation 1319246)
/// Il parco è un MultiPolygon composto da diverse stazioni separate.
final List<Polygon> deltaPoEmiliaPolygons = [
  // STAZIONE 1: VOLANO - MESOLA - GORO
  Polygon(
    points: const [
      LatLng(44.960252, 12.235541),
      LatLng(44.958821, 12.239241),
      LatLng(44.955412, 12.246512),
      LatLng(44.951234, 12.258821),
      LatLng(44.945512, 12.271234),
      LatLng(44.938821, 12.281234),
      LatLng(44.931200, 12.285400),
      LatLng(44.918821, 12.295512),
      LatLng(44.905512, 12.301234),
      LatLng(44.898451, 12.301234),
      LatLng(44.885512, 12.308821),
      LatLng(44.871234, 12.312345),
      LatLng(44.854900, 12.313400),
      LatLng(44.848821, 12.291234),
      LatLng(44.842000, 12.260000),
      LatLng(44.832212, 12.245512),
      LatLng(44.825000, 12.230000),
      LatLng(44.821234, 12.181234),
      LatLng(44.835512, 12.165512),
      LatLng(44.851234, 12.121234),
      LatLng(44.868821, 12.105512),
      LatLng(44.885512, 12.088821),
      LatLng(44.905512, 12.075512),
      LatLng(44.921234, 12.061234),
      LatLng(44.938821, 12.051234),
      LatLng(44.955512, 12.045512),
      LatLng(44.960252, 12.235541),
    ],
    color: Colors.pinkAccent.withValues(alpha: 0.18),
    borderColor: Colors.pinkAccent.withValues(alpha: 0.75),
    borderStrokeWidth: 2,
  ),

  // STAZIONE 3: VALLI DI COMACCHIO (Area enorme e complessa)
  Polygon(
    points: const [
      LatLng(44.695500, 12.185000),
      LatLng(44.685512, 12.205512),
      LatLng(44.671234, 12.221234),
      LatLng(44.651234, 12.241234),
      LatLng(44.635512, 12.245512),
      LatLng(44.615512, 12.258821),
      LatLng(44.605000, 12.256000),
      LatLng(44.588821, 12.252212),
      LatLng(44.568000, 12.224000),
      LatLng(44.555512, 12.195512),
      LatLng(44.545000, 12.162000),
      LatLng(44.555512, 12.135512),
      LatLng(44.571234, 12.101234),
      LatLng(44.585512, 12.115512),
      LatLng(44.594000, 12.124000),
      LatLng(44.612212, 12.135512),
      LatLng(44.631234, 12.148821),
      LatLng(44.643200, 12.155500),
      LatLng(44.665512, 12.165512),
      LatLng(44.695500, 12.185000),
    ],
    color: Colors.pinkAccent.withValues(alpha: 0.18),
    borderColor: Colors.pinkAccent.withValues(alpha: 0.75),
    borderStrokeWidth: 2,
  ),

  // STAZIONE 5: PINETA DI CLASSE E SALINE DI CERVIA
  Polygon(
    points: const [
      LatLng(44.410000, 12.255000),
      LatLng(44.398821, 12.271234),
      LatLng(44.385000, 12.285000),
      LatLng(44.365512, 12.305512),
      LatLng(44.350000, 12.315000),
      LatLng(44.325512, 12.338821),
      LatLng(44.275000, 12.355000),
      LatLng(44.248000, 12.348000),
      LatLng(44.255000, 12.320000),
      LatLng(44.271234, 12.301234),
      LatLng(44.310000, 12.245000),
      LatLng(44.355512, 12.235512),
      LatLng(44.410000, 12.255000),
    ],
    color: Colors.pinkAccent.withValues(alpha: 0.18),
    borderColor: Colors.pinkAccent.withValues(alpha: 0.75),
    borderStrokeWidth: 2,
  ),

  // STAZIONE 6: CAMPOTTO DI ARGENTA (Zona Ovest distaccata)
  Polygon(
    points: const [
      LatLng(44.585000, 11.835000),
      LatLng(44.595512, 11.815512),
      LatLng(44.615000, 11.785000),
      LatLng(44.635512, 11.795512),
      LatLng(44.655000, 11.820000),
      LatLng(44.641234, 11.845512),
      LatLng(44.612212, 11.858821),
      LatLng(44.585000, 11.835000),
    ],
    color: Colors.pinkAccent.withValues(alpha: 0.18),
    borderColor: Colors.pinkAccent.withValues(alpha: 0.75),
    borderStrokeWidth: 2,
  ),
];
