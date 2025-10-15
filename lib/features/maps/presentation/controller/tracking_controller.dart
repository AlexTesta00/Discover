import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/point_of_interest.dart';
import '../../domain/entities/routing_model.dart';
import '../../domain/use_cases/live_router.dart';
import '../../domain/use_cases/location_service.dart';
import '../../domain/use_cases/map_service.dart';
import '../../domain/use_cases/routing_provider.dart';

class TrackingController extends ChangeNotifier {
  TrackingController({
    required MapController mapController,
    required MapService mapService,
    required RoutingProvider routingProvider,
  })  : _mapController = mapController,
        _mapUtils = mapService,
        _routing = routingProvider;

  // deps
  final MapController _mapController;
  final MapService _mapUtils;
  final RoutingProvider _routing;

  // stato posizione
  LatLng? _userLatLng;
  LatLng? get userLatLng => _userLatLng;

  Stream<LatLng>? _positionStream;
  StreamSubscription<LatLng>? _positionSub;

  // routing live
  LiveRouter? _liveRouter;
  StreamSubscription<RouteResult>? _routeSub;

  // polyline rimanente
  final List<LatLng> _remainingRoute = [];
  List<LatLng> get remainingRoute => List.unmodifiable(_remainingRoute);

  final Distance _dist = const Distance();

  // ETA/distanza live
  double _remainMeters = 0;
  double get remainMeters => _remainMeters;
  double _etaSeconds = 0;
  double get etaSeconds => _etaSeconds;
  double _lastSpeedMps = 1.4; // fallback (~5 km/h)

  // trim ogni 10 m
  LatLng? _lastUserPosForTrim;
  double _metersSinceLastTrim = 0.0;
  static const double _TRIM_EVERY_METERS = 10.0;

  // tracking state
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  bool _arrivalShown = false;

  // POI selezionato
  PredefinedPoi? _selectedPoi;
  PredefinedPoi? get selectedPoi => _selectedPoi;

  // callback esterno per aprire il modal di arrivo
  void Function(PredefinedPoi poi)? onArrived;

  // --- LIFECYCLE --------------------------------------------------------------

  Future<void> startLocation() async {
    final pos = await LocationService.ensurePermissionAndGetCurrent();
    if (pos == null) return;

    _userLatLng = pos;
    _mapController.move(pos, 16);
    notifyListeners();

    _positionStream ??= LocationService.positionStream(distanceFilterMeters: 5);
    _positionSub = _positionStream!.listen(_onPosition);
  }

  void disposeAll() {
    _positionSub?.cancel();
    _routeSub?.cancel();
    _liveRouter?.stop();
  }

  // --- ACTIONS ---------------------------------------------------------------

  bool isNearPoi(PredefinedPoi poi, {double toleranceMeters = 20}) {
    if (_userLatLng == null) return false;
    return _dist.as(LengthUnit.Meter, _userLatLng!, poi.position) <= toleranceMeters;
  }

  void selectPoi(PredefinedPoi poi) {
    _selectedPoi = poi;
    notifyListeners();
  }

  void startLiveToSelectedPoi() {
    if (_selectedPoi == null || _userLatLng == null || _positionStream == null) return;

    _arrivalShown = false;
    _routeSub?.cancel();
    _liveRouter?.stop();

    _liveRouter = LiveRouter(
      provider: _routing,
      profile: RouteProfile.foot, // o RouteProfile.bike
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
    _isTracking = true;
    notifyListeners();
  }

  void stopTracking() {
    _routeSub?.cancel();
    _routeSub = null;
    _liveRouter?.stop();
    _liveRouter = null;
    _remainingRoute.clear();
    _mapUtils.clearPaths();
    _remainMeters = 0;
    _etaSeconds = 0;
    _isTracking = false;
    notifyListeners();
  }

  void _onPosition(LatLng newPos) {
    _userLatLng = newPos;

    // trim ogni 10 m
    if (_lastUserPosForTrim != null) {
      _metersSinceLastTrim += _dist.as(LengthUnit.Meter, _lastUserPosForTrim!, newPos);
    }
    _lastUserPosForTrim = newPos;

    if (_metersSinceLastTrim >= _TRIM_EVERY_METERS) {
      _trimTraveledRoute(newPos);
      _metersSinceLastTrim = 0.0;
    }

    _recomputeProgress(newPos);
    _updatePolyline();
    _mapController.move(newPos, _mapController.camera.zoom);

    notifyListeners();
  }

  void _trimTraveledRoute(LatLng userPos) {
    if (_remainingRoute.length < 2 || !_isTracking) return;

    const thresholdMeters = 15.0;
    const arriveMeters = 20.0;

    while (_remainingRoute.length > 1 &&
        _dist.as(LengthUnit.Meter, userPos, _remainingRoute.first) < thresholdMeters) {
      _remainingRoute.removeAt(0);
    }

    // arrivo automatico (una volta sola)
    if (!_arrivalShown &&
        (_remainingRoute.length <= 1 ||
            _dist.as(LengthUnit.Meter, userPos, _remainingRoute.last) <= arriveMeters)) {
      _arrivalShown = true;
      final poi = _selectedPoi;
      stopTracking();
      if (poi != null && onArrived != null) {
        onArrived!(poi);
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
  }

  void _updatePolyline() {
    _mapUtils.clearPaths();
    if (_remainingRoute.length > 1 && _isTracking) {
      _mapUtils.addPath(List<LatLng>.from(_remainingRoute));
    }
  }
}
