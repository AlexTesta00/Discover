// lib/features/maps/presentation/pages/map_gate.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/domain/entities/routing_model.dart';
import 'package:discover/features/maps/domain/use_cases/live_router.dart';
import 'package:discover/features/maps/domain/use_cases/location_service.dart';
import 'package:discover/features/maps/domain/use_cases/map_service.dart';
import 'package:discover/features/maps/domain/use_cases/osrm_routing_provider.dart';
import 'package:discover/features/maps/domain/use_cases/routing_provider.dart';

import 'package:discover/features/maps/presentation/widgets/map_view.dart';
import 'package:discover/features/maps/presentation/widgets/poi_bottom_sheet.dart';
import 'package:discover/features/maps/presentation/widgets/poi_arrival_sheet.dart';
import 'package:discover/utils/presentation/pages/loading_page.dart';

import 'package:discover/features/character/domain/entities/character.dart';
import 'package:discover/features/character/domain/use_cases/character_service.dart';
import 'package:discover/features/character/presentation/pages/character_detail_page.dart';

class MapGate extends StatefulWidget {
  const MapGate({super.key});
  @override
  State<MapGate> createState() => _MapGateState();
}

class _MapGateState extends State<MapGate> {
  final MapController _mapController = MapController();
  final MapService _mapUtils = MapService();
  final RoutingProvider _routing = OSRMRoutingProvider();

  static const LatLng _riccioneCenter = LatLng(43.9992, 12.6563);

  // posizione utente
  LatLng? _userLatLng;
  Stream<LatLng>? _positionStream;
  StreamSubscription<LatLng>? _positionSub;

  // live routing
  LiveRouter? _liveRouter;
  StreamSubscription<RouteResult>? _routeSub;

  // percorso rimanente
  final List<LatLng> _remainingRoute = [];
  final Distance _dist = const Distance();

  // ETA/distanza live
  double _remainMeters = 0;
  double _etaSeconds = 0;
  double _lastSpeedMps = 1.4;

  // gestione trim ogni 10 m
  LatLng? _lastUserPosForTrim;
  double _metersSinceLastTrim = 0.0;
  static const double _TRIM_EVERY_METERS = 10.0;

  // POI e personaggi
  List<PredefinedPoi> _pois = [];
  bool _loadingPois = true;
  String? _poisError;
  Map<String, Character> _charactersById = {};

  PredefinedPoi? _selectedPoi;
  bool _isTracking = false;
  bool _arrivalShown = false;

  @override
  void initState() {
    super.initState();
    _loadPois();
    _startAutomaticLocationTracking();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _routeSub?.cancel();
    _liveRouter?.stop();
    super.dispose();
  }

  Future<void> _loadPois() async {
    try {
      final characters = await CharactersApi().getAllCharacters();
      _charactersById = {for (final c in characters) c.id: c};

      final mapped = characters.map<PredefinedPoi>((c) {
        return PredefinedPoi(
          id: c.id,
          name: c.name,
          position: LatLng(c.lat, c.lng),
          imageAsset: c.imageAsset,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _pois = mapped;
        _loadingPois = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _poisError = e.toString();
        _loadingPois = false;
      });
      _showSnack('Errore caricamento personaggi: $e');
    }
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

      if (_lastUserPosForTrim != null) {
        _metersSinceLastTrim +=
            _dist.as(LengthUnit.Meter, _lastUserPosForTrim!, newPos);
      }
      _lastUserPosForTrim = newPos;

      if (_metersSinceLastTrim >= _TRIM_EVERY_METERS) {
        _trimTraveledRoute(newPos);
        _metersSinceLastTrim = 0.0;
      }

      _recomputeProgress(newPos);
      _updatePolyline();
      _mapController.move(newPos, _mapController.camera.zoom);
    });
  }

  void _startLiveToSelectedPoi() {
    if (_selectedPoi == null || _userLatLng == null || _positionStream == null) return;

    _arrivalShown = false;
    _routeSub?.cancel();
    _liveRouter?.stop();

    _liveRouter = LiveRouter(
      provider: _routing,
      profile: RouteProfile.foot,
      positionStream: _positionStream!,
      targets: [_selectedPoi!.position],
      offRouteThresholdMeters: 25,
      minRerouteInterval: const Duration(seconds: 5),
    );

    _routeSub = _liveRouter!.routeStream.listen((route) {
      _remainingRoute
        ..clear()
        ..addAll(route.geometry);

      if (route.distanceMeters > 1 && route.durationSeconds > 0) {
        _lastSpeedMps = route.distanceMeters / route.durationSeconds;
      }

      if (_userLatLng != null) {
        _recomputeProgress(_userLatLng!);
      } else {
        _remainMeters = route.distanceMeters;
        _etaSeconds = _remainMeters / _lastSpeedMps;
      }

      _updatePolyline();

      if (_remainingRoute.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(_remainingRoute);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
        );
      }
    });

    _liveRouter!.start(_userLatLng!);
    setState(() => _isTracking = true);
  }

  void _stopTracking() {
    _routeSub?.cancel();
    _routeSub = null;
    _liveRouter?.stop();
    _liveRouter = null;
    _remainingRoute.clear();
    _mapUtils.clearPaths();
    _remainMeters = 0;
    _etaSeconds = 0;
    setState(() => _isTracking = false);
  }

  bool _isNearPoi(PredefinedPoi poi, {double toleranceMeters = 20}) {
    if (_userLatLng == null) return false;
    return _dist.as(LengthUnit.Meter, _userLatLng!, poi.position) <= toleranceMeters;
  }

  void _trimTraveledRoute(LatLng userPos) {
    if (_remainingRoute.length < 2 || !_isTracking) return;

    const thresholdMeters = 15.0;
    const arriveMeters = 20.0;

    while (_remainingRoute.length > 1 &&
        _dist.as(LengthUnit.Meter, userPos, _remainingRoute.first) < thresholdMeters) {
      _remainingRoute.removeAt(0);
    }

    // auto-apertura arrivo
    if (!_arrivalShown &&
        (_remainingRoute.length <= 1 ||
         _dist.as(LengthUnit.Meter, userPos, _remainingRoute.last) <= arriveMeters)) {
      _arrivalShown = true;
      final poi = _selectedPoi;
      _stopTracking();
      if (poi != null && mounted) {
        _showArrivalModal(poi);
      }
    }
  }

  void _recomputeProgress(LatLng userPos) {
    if (!_isTracking || _remainingRoute.isEmpty) {
      _remainMeters = 0;
      _etaSeconds = 0;
      return;
    }

    double left = _dist.as(LengthUnit.Meter, userPos, _remainingRoute.first);
    for (int i = 0; i < _remainingRoute.length - 1; i++) {
      left += _dist.as(LengthUnit.Meter, _remainingRoute[i], _remainingRoute[i + 1]);
    }

    _remainMeters = left.clamp(0, double.infinity);
    final speed = _lastSpeedMps > 0 ? _lastSpeedMps : 1.4;
    _etaSeconds = _remainMeters / speed;
    setState(() {});
  }

  void _updatePolyline() {
    _mapUtils.clearPaths();
    if (_remainingRoute.length > 1 && _isTracking) {
      _mapUtils.addPath(List<LatLng>.from(_remainingRoute));
    }
  }

  void _onPoiTap(PredefinedPoi poi) {
    _selectedPoi = poi;

    if (_isNearPoi(poi)) {
      _showArrivalModal(poi);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PoiBottomSheet(
        poi: poi,
        onStart: () {
          Navigator.of(ctx).pop();
          _startLiveToSelectedPoi();
        },
      ),
    );
  }

  void _showArrivalModal(PredefinedPoi poi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PoiArrivalSheet(
        poi: poi,
        onReadStory: () {
          Navigator.of(ctx).pop();
          final character = _charactersById[poi.id];
          if (character != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CharacterDetailPage(character: character),
              ),
            );
          } else {
            _showSnack('Dati del personaggio non disponibili.');
          }
        },
      ),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000.0;
      return '${km.toStringAsFixed(km < 10 ? 1 : 0)} km';
    }
    return '${meters.toStringAsFixed(0)} m';
  }

  String _formatEta(double seconds) {
    if (seconds <= 0) return '0 min';
    final m = (seconds / 60).floor();
    final s = (seconds % 60).round();
    if (m >= 60) {
      final h = (m / 60).floor();
      final mm = m % 60;
      return '${h}h ${mm}m';
    }
    return s > 0 ? '${m}m ${s}s' : '${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final showBanner = _isTracking && (_remainMeters > 0 || _etaSeconds > 0);

    return Scaffold(
      body: Stack(
        children: [
          MapView(
            mapController: _mapController,
            mapUtils: _mapUtils,
            initialCenter: _riccioneCenter,
            userLatLng: _userLatLng,
            pois: _pois,
            onPoiTap: _onPoiTap,
          ),

          if (showBanner)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.near_me),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Distanza: ${_formatDistance(_remainMeters)} · Tempo: ${_formatEta(_etaSeconds)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _stopTracking,
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_loadingPois)
            const Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: LoadingPage(),
            ),
          if (_poisError != null)
            Positioned(
              top: 60,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'Errore: $_poisError',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
