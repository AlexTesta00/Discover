// features/maps/presentation/controller/itinerary_controller.dart
import 'dart:async';
import 'package:discover/features/maps/domain/entities/location_tracker.dart';
import 'package:discover/features/maps/domain/entities/points_repository.dart';
import 'package:discover/features/maps/domain/entities/rewards_service.dart';
import 'package:discover/features/maps/domain/entities/route_service_port.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'itinerary_state.dart';

typedef MessageSink = void Function(String message);
typedef RewardDialog =
    Future<void> Function({required int xp, required int flamingo});

class ItineraryController extends ChangeNotifier {
  final PointsRepository pointsRepo;
  final RouteServicePort routeService;
  final LocationTracker locationTracker;
  final RewardsService rewardsService;
  final MessageSink onMessage;
  final RewardDialog onRewardDialog;

  ItineraryState _state = const ItineraryState();
  ItineraryState get state => _state;

  StreamSubscription<UserPose>? _poseSub;

  ItineraryController({
    required this.pointsRepo,
    required this.routeService,
    required this.locationTracker,
    required this.rewardsService,
    required this.onMessage,
    required this.onRewardDialog,
  });

  // ---------- Lifecycle ----------
  Future<void> init() async {
    await _loadPoints();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _poseSub?.cancel();
    super.dispose();
  }

  // ---------- Data loading ----------
  Future<void> _loadPoints() async {
    try {
      final points = await pointsRepo.loadAvailable();
      _emit(_state.copyWith(availablePoints: points));
    } catch (e) {
      onMessage('Errore caricamento POI: $e');
    }
  }

  void _startLocationTracking() {
    _poseSub?.cancel();
    _poseSub = locationTracker.poseStream(distanceFilterMeters: 1).listen((
      pose,
    ) {
      _emit(_state.copyWith(userPose: pose));
      if (_state.isItineraryActive && _state.routePoints.isNotEmpty) {
        _updateRouteProgress(pose.position);
        _checkReachedPoints();
        _checkRouteDeviation(pose.position);
      }
    });
  }

  // ---------- User actions ----------
  void toggleMapExpanded() =>
      _emit(_state.copyWith(isMapExpanded: !_state.isMapExpanded));

  void selectPoint(PointOfInterest p) {
    final selected = [..._state.selectedPoints, p];
    final markers = _addMarker(_state.markers, p.position);
    _emit(_state.copyWith(selectedPoints: selected, markers: markers));
  }

  void deselectPoint(PointOfInterest p) {
    final selected = _state.selectedPoints
        .where((e) => e != p)
        .toList(growable: false);
    final markers = _state.markers
        .where((m) => m.position != p.position)
        .toList(growable: false);
    _emit(_state.copyWith(selectedPoints: selected, markers: markers));
  }

  Future<void> startItinerary(String profile) async {
    final ok = await locationTracker.ensureReady();
    if (!ok) return;

    if (_state.selectedPoints.length < 2) {
      onMessage('Seleziona almeno 2 punti');
      return;
    }

    final user = _state.userPose ?? await locationTracker.currentPose();
    final points = _state.selectedPoints.map((p) => p.position).toList();
    points.insert(0, user.position);

    try {
      final route = await routeService.getRoute(points, profile: profile);
      _emit(
        _state.copyWith(
          routePoints: route,
          isItineraryActive: true,
          currentRouteIndex: 0,
          selectedProfile: profile,
          userPose: user,
        ),
      );
    } catch (e) {
      onMessage('Errore percorso: $e');
    }
  }

  void finishItinerary() {
    _emit(
      _state.copyWith(
        isItineraryActive: false,
        selectedPoints: const [],
        markers: const [],
        routePoints: const [],
        currentRouteIndex: 0,
      ),
    );
    onMessage('Itinerario terminato.');
  }

  Future<void> recalculateRoute() async {
    if (_state.selectedPoints.isEmpty ||
        !_state.isItineraryActive ||
        _state.userPose == null)
      return;

    final points = _state.selectedPoints.map((p) => p.position).toList();
    points.insert(0, _state.userPose!.position);

    try {
      final route = await routeService.getRoute(
        points,
        profile: _state.selectedProfile,
      );
      _emit(_state.copyWith(routePoints: route, currentRouteIndex: 0));
    } catch (e) {
      onMessage('Errore nel ricalcolo del percorso: $e');
    }
  }

  // ---------- Private helpers ----------
  void _emit(ItineraryState next) {
    _state = next;
    notifyListeners();
  }

  List<PointOfInterest> _addMarker(
    List<PointOfInterest> markers,
    LatLng position,
  ) {
    final exists = markers.any((m) => m.position == position);
    if (exists) return markers;

    return [
      ...markers,
      PointOfInterest(
        title: "Marker",
        description: "Punto selezionato manualmente",
        position: position,
      ),
    ];
  }

  void _updateRouteProgress(LatLng userPos) {
    if (_state.currentRouteIndex >= _state.routePoints.length - 1) return;

    const double threshold = 8.0; // metri
    final target = _state.routePoints[_state.currentRouteIndex];
    final dist = const Distance().as(LengthUnit.Meter, userPos, target);

    if (dist < threshold) {
      final newIndex = _state.currentRouteIndex + 1;
      final newRoute = _state.routePoints.sublist(newIndex);
      _emit(
        _state.copyWith(currentRouteIndex: newIndex, routePoints: newRoute),
      );
    }
  }

  Future<void> _checkReachedPoints() async {
    final pose = _state.userPose;
    if (pose == null || !_state.isItineraryActive) return;

    const threshold = 20.0; // metri
    final reached = _state.selectedPoints
        .where((point) {
          final d = const Distance().as(
            LengthUnit.Meter,
            pose.position,
            point.position,
          );
          return d < threshold;
        })
        .toList(growable: false);

    if (reached.isEmpty) return;

    for (final _ in reached) {
      await rewardsService.reward(xp: 50, flamingo: 50);
      await onRewardDialog(xp: 50, flamingo: 50);
    }

    final remaining = _state.selectedPoints
        .where((p) => !reached.contains(p))
        .toList(growable: false);
    final remainingMarkers = _state.markers
        .where((m) => !reached.map((r) => r.position).contains(m.position))
        .toList(growable: false);

    _emit(
      _state.copyWith(selectedPoints: remaining, markers: remainingMarkers),
    );
    await recalculateRoute();

    if (remaining.isEmpty) finishItinerary();
  }

  void _checkRouteDeviation(LatLng userPos) {
    const deviationThreshold = 10.0; // metri
    final nearAny = _state.routePoints.any(
      (p) =>
          const Distance().as(LengthUnit.Meter, userPos, p) <
          deviationThreshold,
    );
    if (!nearAny) {
      debugPrint('Utente fuori rotta, ricalcolo...');
      Future.microtask(recalculateRoute);
    }
  }
}
