import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapService extends ChangeNotifier {
  final Distance _distance = const Distance();

  // Stato interno
  final List<LatLng> _points = [];
  final List<List<LatLng>> _paths = [];

  // ---- GETTER PUBBLICI ----

  /// Punti "grezzi" aggiunti dall'utente (serve alla MapPage per il routing)
  List<LatLng> get pointsRaw => List.unmodifiable(_points);

  /// Markers costruiti dai punti (per il MarkerLayer)
  List<Marker> get markers => _points
      .map(
        (p) => Marker(
          point: p,
          width: 28,
          height: 28,
          child: _removableMarker(p),
        ),
      )
      .toList();

  /// Polilinee da disegnare (percorsi manuali + live routing)
  List<Polyline> get polylines => _paths
      .map(
        (path) => Polyline(points: path, strokeWidth: 4),
      )
      .toList();

  // ---- API PUNTI ----

  void addPoint(LatLng p) {
    _points.add(p);
    notifyListeners();
  }

  /// Rimuove il punto più vicino a [p] se entro [thresholdMeters].
  bool removePointNear(LatLng p, {double thresholdMeters = 30}) {
    if (_points.isEmpty) return false;

    int? nearestIdx;
    double nearestDist = double.infinity;

    for (int i = 0; i < _points.length; i++) {
      final d = _distance.as(LengthUnit.Meter, p, _points[i]);
      if (d < nearestDist) {
        nearestDist = d;
        nearestIdx = i;
      }
    }

    if (nearestIdx != null && nearestDist <= thresholdMeters) {
      _points.removeAt(nearestIdx);
      notifyListeners();
      return true;
    }
    return false;
  }

  void removeExactPoint(LatLng p) {
    _points.removeWhere((e) => e == p);
    notifyListeners();
  }

  void clearPoints() {
    _points.clear();
    notifyListeners();
  }

  // ---- API PERCORSI (Polyline) ----

  void addPath(List<LatLng> path) {
    if (path.length < 2) return;
    _paths.add(List<LatLng>.from(path));
    notifyListeners();
  }

  /// Collega i punti in ordine (demo/manuale, NON fa routing su strade)
  void buildPathFromPoints({bool closeLoop = false}) {
    if (_points.length < 2) return;
    final path = List<LatLng>.from(_points);
    if (closeLoop) path.add(_points.first);
    addPath(path);
  }

  void clearPaths() {
    _paths.clear();
    notifyListeners();
  }

  void clearAll() {
    _points.clear();
    _paths.clear();
    notifyListeners();
  }

  // ---- Marker tappabile per rimozione precisa ----
  Widget _removableMarker(LatLng p) {
    return GestureDetector(
      onTap: () => removeExactPoint(p),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Colors.black26),
          ],
        ),
        child: const Center(
          child: Icon(Icons.place, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
