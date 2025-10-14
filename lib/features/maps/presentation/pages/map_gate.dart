// lib/features/maps/presentation/pages/map_gate.dart
import 'dart:async';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/domain/entities/routing_model.dart';
import 'package:discover/features/maps/domain/use_cases/live_router.dart';
import 'package:discover/features/maps/domain/use_cases/location_service.dart';
import 'package:discover/features/maps/domain/use_cases/map_service.dart';
import 'package:discover/features/maps/domain/use_cases/osrm_routing_provider.dart';
import 'package:discover/features/maps/domain/use_cases/routing_provider.dart';
import 'package:discover/features/maps/presentation/widgets/map_view.dart';
import 'package:discover/features/maps/presentation/widgets/poi_arrival_sheet.dart';
import 'package:discover/features/maps/presentation/widgets/poi_bottom_sheet.dart';
import 'package:discover/utils/presentation/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:discover/features/character/domain/use_cases/character_service.dart';

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

  LatLng? _userLatLng;
  Stream<LatLng>? _positionStream;
  StreamSubscription<LatLng>? _positionSub;

  LiveRouter? _liveRouter;
  StreamSubscription<RouteResult>? _routeSub;

  final List<LatLng> _remainingRoute = [];

  List<PredefinedPoi> _pois = [];
  bool _loadingPois = true;
  String? _poisError;

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
      _trimTraveledRoute(newPos);
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
    _mapUtils.clearPaths(); // rimuove la linea
    setState(() => _isTracking = false);
  }

  void _trimTraveledRoute(LatLng userPos) {
    if (_remainingRoute.length < 2 || !_isTracking) return;

    const thresholdMeters = 15.0;
    const arriveMeters = 10.0;
    final dist = const Distance();

    while (_remainingRoute.length > 1 &&
        dist.as(LengthUnit.Meter, userPos, _remainingRoute.first) < thresholdMeters) {
      _remainingRoute.removeAt(0);
    }

    if (!_arrivalShown &&
        (_remainingRoute.length <= 1 ||
         dist.as(LengthUnit.Meter, userPos, _remainingRoute.last) <= arriveMeters)) {
      _arrivalShown = true;
      final poi = _selectedPoi;
      _stopTracking();
      if (poi != null && mounted) {
        _showArrivalModal(poi);
      }
    }
  }

  void _updatePolyline() {
    _mapUtils.clearPaths();
    if (_remainingRoute.length > 1 && _isTracking) {
      _mapUtils.addPath(List<LatLng>.from(_remainingRoute));
    }
  }

  void _onPoiTap(PredefinedPoi poi) {
    _selectedPoi = poi;
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

  // Modal di ARRIVO (come nello screenshot)
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          if (_loadingPois)
            const Positioned(
              top: 48,
              left: 0,
              right: 0,
              child: LoadingPage(),
            ),
          if (_poisError != null)
            Positioned(
              top: 48,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text('Errore: $_poisError', style: const TextStyle(color: Colors.white)),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isTracking
          ? FloatingActionButton.extended(
              heroTag: 'stopTracking',
              onPressed: _stopTracking,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Stop tracking'),
            )
          : null,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
