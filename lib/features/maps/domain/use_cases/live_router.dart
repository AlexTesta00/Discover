import 'dart:async';
import 'dart:math' as math;
import 'package:discover/features/maps/domain/entities/routing_model.dart';
import 'package:latlong2/latlong.dart';
import 'routing_provider.dart';

typedef RouteUpdate = void Function(RouteResult route);

class LiveRouter {
  final RoutingProvider provider;
  final RouteProfile profile;
  final Stream<LatLng> positionStream;

  /// Punti target da raggiungere (es. POI, tap utente). Il primo viene raggiunto,
  final List<LatLng> targets;

  /// Ricalcola se ci si discosta dalla rotta oltre questa soglia
  final double offRouteThresholdMeters;

  /// Debounce tra richieste routing
  final Duration minRerouteInterval;

  final Distance _distance = const Distance();

  StreamSubscription<LatLng>? _sub;
  RouteResult? _currentRoute;
  DateTime _lastReroute = DateTime.fromMillisecondsSinceEpoch(0);

  final _ctrl = StreamController<RouteResult>.broadcast();
  Stream<RouteResult> get routeStream => _ctrl.stream;

  LiveRouter({
    required this.provider,
    required this.profile,
    required this.positionStream,
    required this.targets,
    this.offRouteThresholdMeters = 25,
    this.minRerouteInterval = const Duration(seconds: 5),
  });

  Future<void> start(LatLng initialUser) async {
    await _rebuildRoute(initialUser);
    _sub = positionStream.listen(_onPos);
  }

  Future<void> stop() async {
    await _sub?.cancel();
    await _ctrl.close();
  }

  Future<void> _onPos(LatLng p) async {
    if (_currentRoute == null) return;

    // fuori rotta?
    final d = _minDistanceToPolyline(p, _currentRoute!.geometry);
    final now = DateTime.now();
    final enoughTime = now.difference(_lastReroute) >= minRerouteInterval;

    if (d > offRouteThresholdMeters && enoughTime) {
      _lastReroute = now;
      await _rebuildRoute(p);
    }
  }

  Future<void> _rebuildRoute(LatLng user) async {
    // Ignora target già superati (se molto vicini)
    final remaining = <LatLng>[];
    for (final t in targets) {
      final d = _distance.as(LengthUnit.Meter, user, t);
      if (d > 8) remaining.add(t);
    }
    if (remaining.isEmpty) return;

    final waypoints = [user, ...remaining];
    final r = await provider.route(profile: profile, waypoints: waypoints);
    _currentRoute = r;
    if (!_ctrl.isClosed) _ctrl.add(r);
  }

  /// distanza minima punto-linea
  double _minDistanceToPolyline(LatLng p, List<LatLng> line) {
    if (line.length < 2) return double.infinity;
    double best = double.infinity;
    for (int i = 0; i < line.length - 1; i++) {
      final d = _pointToSegmentMeters(p, line[i], line[i + 1]);
      if (d < best) best = d;
    }
    return best;
  }

  double _pointToSegmentMeters(LatLng p, LatLng a, LatLng b) {
    // proiezione su segmento in coordinate geografiche (approssimazione metrica locale)
    // Convertiamo lat/lon in metri locali usando equirettangolare semplice
    // (sufficientemente precisa su segmenti piccoli).
    const double R = 6371000; // raggio terrestre
    double toRad(double deg) => deg * 3.141592653589793 / 180.0;

    final lat = toRad(p.latitude);
    final lon = toRad(p.longitude);
    final lat1 = toRad(a.latitude);
    final lon1 = toRad(a.longitude);
    final lat2 = toRad(b.latitude);
    final lon2 = toRad(b.longitude);

    final x = (lon - lon1) * MathCos((lat1 + lat2) / 2) * R;
    final y = (lat - lat1) * R;
    final x1 = 0.0;
    final y1 = 0.0;
    final x2 = (lon2 - lon1) * MathCos((lat1 + lat2) / 2) * R;
    final y2 = (lat2 - lat1) * R;

    final dx = x2 - x1;
    final dy = y2 - y1;
    final t = (dx == 0 && dy == 0) ? 0.0 : ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy);
    final tt = t.clamp(0.0, 1.0);
    final xp = x1 + tt * dx;
    final yp = y1 + tt * dy;
    final ddx = x - xp;
    final ddy = y - yp;
    return MathSqrt(ddx * ddx + ddy * ddy);
  }
}

// ignore: non_constant_identifier_names
double MathCos(double v) => (v).cos();
// ignore: non_constant_identifier_names
double MathSqrt(double v) => (v).sqrt();

extension _NumMath on double {
  double cos() => (double.parse('$this'))._cos();
  double _cos() {
    // usa dart:math senza esportarlo
    return _mathCos(this);
  }
  double sqrt() => _mathSqrt(this);
}


double _mathCos(double v) => math.cos(v);
double _mathSqrt(double v) => math.sqrt(v);
