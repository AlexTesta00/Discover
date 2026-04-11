import 'dart:async';

import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/point_of_interest.dart';
import '../../domain/entities/routing_model.dart';
import '../../domain/use_cases/live_router.dart';
import '../../domain/use_cases/map_service.dart';
import '../../domain/use_cases/osrm_routing_provider.dart';
import '../../domain/use_cases/routing_provider.dart';

import '../widgets/map_view.dart';
import '../widgets/banner.dart';
import '../widgets/off_screen_indicators.dart';
import '../widgets/poi_arrival_sheet.dart';
import '../widgets/poi_bottom_sheet.dart';

import 'package:discover/features/character/domain/entities/character.dart';
import 'package:discover/features/character/domain/use_cases/character_service.dart';
import 'package:discover/features/character/presentation/pages/character_detail_page.dart';
import 'package:discover/features/maps/presentation/pages/ar_character_page.dart';

class DemoTrackingController extends ChangeNotifier {
  DemoTrackingController({
    required MapController mapController,
    required MapService mapService,
    required RoutingProvider routingProvider,
  }) : _mapController = mapController,
       _mapUtils = mapService,
       _routing = routingProvider;

  final MapController _mapController;
  final MapService _mapUtils;
  final RoutingProvider _routing;

  final Distance _dist = const Distance();

  LatLng? _userLatLng;
  LatLng? get userLatLng => _userLatLng;

  final StreamController<LatLng> _posCtrl =
      StreamController<LatLng>.broadcast();
  Stream<LatLng> get positionStream => _posCtrl.stream;

  LiveRouter? _liveRouter;
  StreamSubscription<RouteResult>? _routeSub;

  final List<LatLng> _remainingRoute = [];
  List<LatLng> get remainingRoute => List.unmodifiable(_remainingRoute);

  double _remainMeters = 0;
  double get remainMeters => _remainMeters;

  double _etaSeconds = 0;
  double get etaSeconds => _etaSeconds;

  double _lastSpeedMps = 1.4;

  bool _isTracking = false;
  bool get isTracking => _isTracking;

  bool _arrivalShown = false;

  LatLng? _lastUserPosForTrim;
  double _metersSinceLastTrim = 0.0;
  // ignore: constant_identifier_names
  static const double _TRIM_EVERY_METERS = 10.0;

  PredefinedPoi? _selectedPoi;
  PredefinedPoi? get selectedPoi => _selectedPoi;

  static const double _followZoom = 17.0;

  void Function(PredefinedPoi poi)? onArrived;

  /// Post-frame + try/catch + retry: robusto con PersistentTabView / warm start.
  void _safe(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        fn();
      } catch (_) {
        // Retry una seconda volta: spesso basta con navigator annidati/tab caching
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            fn();
          } catch (_) {}
        });
      }
    });
  }

  void disposeAll() {
    _routeSub?.cancel();
    _liveRouter?.stop();
    _posCtrl.close();
  }

  /// NON usare MapController qui: la mappa potrebbe non essere ancora renderizzata.
  void setInitialUser(LatLng p) {
    _userLatLng = p;
    notifyListeners();
  }

  void teleportUser(LatLng p, {bool moveCamera = true}) {
    _userLatLng = p;

    // simula GPS
    _posCtrl.add(p);

    // aggiorna ETA/trim/polyline
    _onPosition(p);

    if (moveCamera) {
      _safe(() => _mapController.move(p, _followZoom));
    }
    notifyListeners();
  }

  void centerOnUser() {
    if (_userLatLng == null) return;
    _safe(() => _mapController.move(_userLatLng!, _followZoom));
  }

  void resetRotationNorth() => _safe(() => _mapController.rotate(0));

  bool isNearPoi(PredefinedPoi poi, {double toleranceMeters = 20}) {
    if (_userLatLng == null) return false;
    return _dist.as(LengthUnit.Meter, _userLatLng!, poi.position) <=
        toleranceMeters;
  }

  void selectPoi(PredefinedPoi poi) {
    _selectedPoi = poi;
    notifyListeners();
  }

  void startLiveToSelectedPoi() {
    if (_selectedPoi == null || _userLatLng == null) return;

    _arrivalShown = false;
    _routeSub?.cancel();
    _liveRouter?.stop();

    _liveRouter = LiveRouter(
      provider: _routing,
      profile: RouteProfile.foot,
      positionStream: positionStream,
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
        _safe(() {
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(32)),
          );
        });
      }

      notifyListeners();
    });

    // costruisci subito la rotta iniziale
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
    if (_lastUserPosForTrim != null) {
      _metersSinceLastTrim += _dist.as(
        LengthUnit.Meter,
        _lastUserPosForTrim!,
        newPos,
      );
    }
    _lastUserPosForTrim = newPos;

    if (_metersSinceLastTrim >= _TRIM_EVERY_METERS) {
      _trimTraveledRoute(newPos);
      _metersSinceLastTrim = 0.0;
    }

    _recomputeProgress(newPos);
    _updatePolyline();

    // IMPORTANT: move sempre "safe"
    if (_isTracking) {
      _safe(() => _mapController.move(newPos, _followZoom));
    }
  }

  void _trimTraveledRoute(LatLng userPos) {
    if (_remainingRoute.length < 2 || !_isTracking) return;

    const thresholdMeters = 15.0;
    const arriveMeters = 20.0;

    while (_remainingRoute.length > 1 &&
        _dist.as(LengthUnit.Meter, userPos, _remainingRoute.first) <
            thresholdMeters) {
      _remainingRoute.removeAt(0);
    }

    if (!_arrivalShown &&
        (_remainingRoute.length <= 1 ||
            _dist.as(LengthUnit.Meter, userPos, _remainingRoute.last) <=
                arriveMeters)) {
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
      left += _dist.as(
        LengthUnit.Meter,
        _remainingRoute[i],
        _remainingRoute[i + 1],
      );
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

class MapDemoGate extends StatefulWidget {
  const MapDemoGate({super.key});

  @override
  State<MapDemoGate> createState() => _MapDemoGateState();
}

class _MapDemoGateState extends State<MapDemoGate> {
  static const LatLng _demoStart = LatLng(43.9992, 12.6563);

  final MapController _mapController = MapController();
  final MapService _mapUtils = MapService();
  final RoutingProvider _routing = OSRMRoutingProvider();

  late final DemoTrackingController _ctrl = DemoTrackingController(
    mapController: _mapController,
    mapService: _mapUtils,
    routingProvider: _routing,
  )..onArrived = _showArrivalModal;

  List<PredefinedPoi> _pois = [];
  Map<String, Character> _charactersById = {};
  bool _loadingPois = true;
  String? _poisError;
  StreamSubscription? _busSub;

  @override
  void initState() {
    super.initState();

    // niente move qui: ci pensa initialCenter/initialZoom del MapView
    _ctrl.setInitialUser(_demoStart);

    _mapUtils.setPolygons([_mapUtils.deltaDelPoPolygon]);
    _loadPois();

    _busSub = ChallengeEventBus.I.stream.listen((e) {
      if (e is GoToMapForCharacterEvent) {
        _focusPoiByCharacterId(e.characterId);
      }
    });
  }

  @override
  void dispose() {
    _busSub?.cancel();
    _ctrl.disposeAll();
    _ctrl.dispose();
    super.dispose();
  }

  void _focusPoiByCharacterId(String characterId) {
    if (_pois.isEmpty) return;

    final poi = _pois
        .where((p) => p.id == characterId)
        .cast<PredefinedPoi?>()
        .firstOrNull;
    if (poi == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(poi.position, 16);
    });

    _onPoiTap(poi);
  }

  Future<void> _loadPois() async {
    try {
      final characters = await CharactersApi().getAllCharacters();
      if (!mounted) return;
      _charactersById = {for (final c in characters) c.id: c};

      setState(() {
        _pois = characters
            .map(
              (c) => PredefinedPoi(
                id: c.id,
                name: c.name,
                position: LatLng(c.lat, c.lng),
                imageAsset: c.imageAsset,
              ),
            )
            .toList();
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

  void _onPoiTap(PredefinedPoi poi) {
    _ctrl.selectPoi(poi);

    if (_ctrl.isNearPoi(poi)) {
      _showArrivalModal(poi);
      return;
    }

    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PoiBottomSheet(
        poi: poi,
        onStart: () {
          Navigator.of(ctx).pop();
          _ctrl.startLiveToSelectedPoi();
        },
      ),
    );
  }

  void _showArrivalModal(PredefinedPoi poi) async {
    if (!mounted) return;

    Future<void> completeTalkChallengeIfNeeded() async {
      final bus = ChallengeEventBus.I;
      final client = Supabase.instance.client;
      final repo = ChallengeRepository(client);

      try {
        final (submissionId, wasNew) = await repo
            .completeTalkChallengeForCharacter(poi.id);

        if (submissionId != null && wasNew) {
          final allChallenges = await repo.fetchAllWithCharacter();
          final challenge = allChallenges.firstWhere(
            (c) => c.characterId == poi.id && c.requiresPhoto == false,
          );

          bus.publish(
            ChallengeCompletedEvent(
              submissionId: submissionId,
              challenge: challenge,
            ),
          );
        }
      } catch (e) {
        debugPrint('Errore completamento challenge RPC: $e');
        if (mounted) {
          _showSnack('Impossibile completare la challenge: $e');
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PoiArrivalSheet(
        poi: poi,
        onReadStory: () async {
          Navigator.of(ctx).pop();
          await completeTalkChallengeIfNeeded();

          if (!mounted) return;

          final character = _charactersById[poi.id];
          if (character != null) {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => CharacterDetailPage(character: character),
              ),
            );
          } else {
            _showSnack('Dati del personaggio non disponibili.');
          }
        },
        onViewAr: () {
          Navigator.of(ctx).pop();
          final character = _charactersById[poi.id];
          if (character != null) {
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (_) => ARCharacterPage(character: character),
              ),
            );
          } else {
            _showSnack('Dati del personaggio non disponibili.');
          }
        },
      ),
    );
  }

  void _onLongPressTeleport(LatLng p) {
    _ctrl.teleportUser(p);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final showBanner =
            _ctrl.isTracking &&
            (_ctrl.remainMeters > 0 || _ctrl.etaSeconds > 0);

        return Scaffold(
          body: Stack(
            children: [
              MapView(
                mapController: _mapController,
                mapUtils: _mapUtils,
                initialCenter: _demoStart,
                userLatLng: _ctrl.userLatLng,
                pois: _pois,
                onPoiTap: _onPoiTap,
                onLongPressMap: _onLongPressTeleport,
              ),

              if (_pois.isNotEmpty)
                OffScreenPoiIndicators(
                  mapController: _mapController,
                  pois: _pois,
                  userLatLng: _ctrl.userLatLng,
                  onTap: _onPoiTap,
                ),

              EtaBanner(
                visible: showBanner,
                remainMeters: _ctrl.remainMeters,
                etaSeconds: _ctrl.etaSeconds,
                onStop: _ctrl.stopTracking,
              ),

              Positioned(
                right: 12,
                bottom: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'demo_center_user',
                      onPressed: _ctrl.centerOnUser,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      child: const Icon(Icons.my_location),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.small(
                      heroTag: 'demo_reset_north',
                      onPressed: _ctrl.resetRotationNorth,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      child: const Icon(Icons.explore),
                    ),
                  ],
                ),
              ),

              if (_loadingPois)
                const Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator()),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
