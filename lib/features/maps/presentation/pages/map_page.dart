// lib/features/maps/presentation/pages/map_page.dart
import 'dart:async';
import 'package:discover/features/maps/domain/entities/routing_model.dart';
import 'package:discover/features/maps/domain/use_cases/live_router.dart';
import 'package:discover/features/maps/domain/use_cases/location_service.dart';
import 'package:discover/features/maps/domain/use_cases/map_service.dart';
import 'package:discover/features/maps/domain/use_cases/osrm_routing_provider.dart';
import 'package:discover/features/maps/domain/use_cases/routing_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/map_view.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final MapService _mapUtils = MapService();

  static const LatLng _rome = LatLng(41.9028, 12.4964);

  LatLng? _userLatLng;

  // live position
  Stream<LatLng>? _positionStream;
  StreamSubscription<LatLng>? _positionSub;

  // live routing
  LiveRouter? _liveRouter;
  final RoutingProvider _routing = OSRMRoutingProvider();

  // percorso rimanente (quello che disegniamo)
  final List<LatLng> _remainingRoute = [];

  @override
  void initState() {
    super.initState();
    _startAutomaticLocationTracking();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _liveRouter?.stop();
    super.dispose();
  }

  Future<void> _startAutomaticLocationTracking() async {
    final pos = await LocationService.ensurePermissionAndGetCurrent();
    if (pos == null) {
      if (mounted) _showSnack('Geolocalizzazione non disponibile o permessi negati.');
      return;
    }

    setState(() => _userLatLng = pos);
    _mapController.move(pos, 16);

    _positionStream ??= LocationService.positionStream(distanceFilterMeters: 5);
    _positionSub = _positionStream!.listen((LatLng newPos) {
      if (!mounted) return;
      setState(() => _userLatLng = newPos);

      // “consuma” la rotta man mano che ti muovi
      _trimTraveledRoute(newPos);
      _updatePolyline();

      // mantieni la mappa centrata sull’utente
      _mapController.move(newPos, _mapController.camera.zoom);
    });

    _maybeStartOrUpdateLiveRouter(initialUser: pos);
  }

  void _maybeStartOrUpdateLiveRouter({required LatLng initialUser}) {
    final targets = _mapUtils.pointsRaw; // punti aggiunti con long-press
    if (targets.isEmpty || _positionStream == null) {
      _remainingRoute.clear();
      _mapUtils.clearPaths();
      _liveRouter?.stop();
      _liveRouter = null;
      return;
    }

    _liveRouter?.stop();
    _liveRouter = LiveRouter(
      provider: _routing,
      profile: RouteProfile.foot, // o RouteProfile.bike
      positionStream: _positionStream!,
      targets: targets,
      offRouteThresholdMeters: 25,
      minRerouteInterval: const Duration(seconds: 5),
    );

    _liveRouter!.routeStream.listen((route) {
      // nuova rotta calcolata → rimpiazziamo il “remaining”
      _remainingRoute
        ..clear()
        ..addAll(route.geometry);

      // disegna e adatta la camera
      _updatePolyline();
      if (_remainingRoute.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_remainingRoute);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
        );
      }
    });

    _liveRouter!.start(initialUser);
  }

  /// Calcola un percorso “vero” su strada con OSRM: [utente] + punti
  Future<void> _buildRoutedPathFromPoints({RouteProfile profile = RouteProfile.foot}) async {
    final pts = _mapUtils.pointsRaw;
    final waypoints = <LatLng>[
      if (_userLatLng != null) _userLatLng!,
      ...pts,
    ];

    if (waypoints.length < 2) {
      _showSnack('Aggiungi almeno 2 punti (es. tu + una destinazione).');
      return;
    }

    try {
      final result = await _routing.route(profile: profile, waypoints: waypoints);

      _remainingRoute
        ..clear()
        ..addAll(result.geometry);

      _updatePolyline();

      if (_remainingRoute.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_remainingRoute);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
        );
      }
    } catch (e) {
      _showSnack('Routing fallito: $e');
    }
  }

  /// Rimuove i punti della rotta già “passati” dall’utente
  void _trimTraveledRoute(LatLng userPos) {
    if (_remainingRoute.length < 2) return;

    const thresholdMeters = 15.0;
    final dist = const Distance();

    // Finché il primo punto della rotta è vicino all'utente → rimuovi
    while (_remainingRoute.length > 1 &&
        dist.as(LengthUnit.Meter, userPos, _remainingRoute.first) < thresholdMeters) {
      _remainingRoute.removeAt(0);
    }
  }

  /// Ridisegna la polyline in base a _remainingRoute
  void _updatePolyline() {
    _mapUtils.clearPaths();
    if (_remainingRoute.length > 1) {
      _mapUtils.addPath(List<LatLng>.from(_remainingRoute));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapView(
        mapController: _mapController,
        mapUtils: _mapUtils,
        initialCenter: _rome,
        userLatLng: _userLatLng,
        onLongPressAddPoint: (p) {
          _mapUtils.addPoint(p);
          if (_userLatLng != null) {
            _maybeStartOrUpdateLiveRouter(initialUser: _userLatLng!);
          }
        },
        onTapRemoveNear: (p) {
          final removed = _mapUtils.removePointNear(p, thresholdMeters: 30);
          if (removed && _userLatLng != null) {
            _maybeStartOrUpdateLiveRouter(initialUser: _userLatLng!);
          }
        },
      ),

      // Azioni: routing su strada + pulizia
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'routedPath',
            onPressed: () => _buildRoutedPathFromPoints(profile: RouteProfile.foot),
            icon: const Icon(Icons.directions_walk),
            label: const Text('Percorso su strada'),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'clearAll',
            onPressed: () {
              setState(() => _userLatLng = null);
              _remainingRoute.clear();
              _mapUtils.clearAll();
              _liveRouter?.stop();
              _liveRouter = null;
            },
            icon: const Icon(Icons.delete_sweep),
            label: const Text('Pulisci'),
            backgroundColor: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
