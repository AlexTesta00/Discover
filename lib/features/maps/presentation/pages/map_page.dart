import 'dart:async';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/domain/repository/poi_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/routing_model.dart';
import '../../domain/use_cases/live_router.dart';
import '../../domain/use_cases/location_service.dart';
import '../../domain/use_cases/map_service.dart';
import '../../domain/use_cases/osrm_routing_provider.dart';
import '../../domain/use_cases/routing_provider.dart';
import '../widgets/map_view.dart';
import '../widgets/poi_bottom_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  final MapService _mapUtils = MapService();

  static const LatLng _riccioneCenter = LatLng(43.9992, 12.6563);

  LatLng? _userLatLng;
  Stream<LatLng>? _positionStream;
  StreamSubscription<LatLng>? _positionSub;

  LiveRouter? _liveRouter;
  final RoutingProvider _routing = OSRMRoutingProvider();

  final List<LatLng> _remainingRoute = [];
  final List<PredefinedPoi> _pois = poisRiccione;
  PredefinedPoi? _selectedPoi;

  bool _isTracking = false;

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
      _trimTraveledRoute(newPos);
      _updatePolyline();
      _mapController.move(newPos, _mapController.camera.zoom);
    });
  }

  void _startLiveToSelectedPoi() {
    if (_selectedPoi == null || _userLatLng == null || _positionStream == null) return;

    _liveRouter?.stop();
    _liveRouter = LiveRouter(
      provider: _routing,
      profile: RouteProfile.foot,
      positionStream: _positionStream!,
      targets: [_selectedPoi!.position],
      offRouteThresholdMeters: 25,
      minRerouteInterval: const Duration(seconds: 5),
    );

    _liveRouter!.routeStream.listen((route) {
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
    _liveRouter?.stop();
    _liveRouter = null;
    _selectedPoi = null;
    _remainingRoute.clear();
    _mapUtils.clearPaths();
    setState(() => _isTracking = false);
  }

  void _trimTraveledRoute(LatLng userPos) {
    if (_remainingRoute.length < 2 || !_isTracking) return;
    const thresholdMeters = 15.0;
    final dist = const Distance();
    while (_remainingRoute.length > 1 &&
        dist.as(LengthUnit.Meter, userPos, _remainingRoute.first) < thresholdMeters) {
      _remainingRoute.removeAt(0);
    }
  }

  void _updatePolyline() {
    _mapUtils.clearPaths();
    if (_remainingRoute.length > 1 && _isTracking) {
      _mapUtils.addPath(List<LatLng>.from(_remainingRoute));
    }
  }

  // Tap su marker POI → bottom sheet
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapView(
        mapController: _mapController,
        mapUtils: _mapUtils,
        initialCenter: _riccioneCenter,
        userLatLng: _userLatLng,
        pois: _pois,
        onPoiTap: _onPoiTap,
      ),

      // FAB visibile SOLO in tracking
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
