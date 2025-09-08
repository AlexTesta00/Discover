import 'dart:async';

import 'package:discover/core/app_service.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/challenge/presentation/widgets/modal_card.dart';
import 'package:discover/features/gamification/utils.dart';
import 'package:discover/features/maps/data/sources/point_of_interest_remote_data_source.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/domain/use_cases/build_itinerary.dart';
import 'package:discover/features/maps/domain/use_cases/location.dart';
import 'package:discover/features/maps/domain/use_cases/route_service.dart';
import 'package:discover/features/maps/presentation/pages/transport_model_dialog.dart';
import 'package:discover/features/maps/presentation/widgets/point_card.dart';
import 'package:discover/features/maps/presentation/widgets/user_dot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final _mapController = MapController();
  List<PointOfInterest> _markers = const [];
  List<PointOfInterest> _availablePoints = const [];
  List<PointOfInterest> _selectedPoints = const [];
  List<LatLng> _routePoints = [];
  LatLng? _userLocation;
  StreamSubscription<Position>? _positionStream;
  double _heading = 0.0;
  bool _isMapExpanded = false;
  bool _isItineraryActive = false;
  int _currentRouteIndex = 0;
  String _selectedProfile = "foot-walking";

  @override
  void initState() {
    super.initState();
    _loadPoints();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _loadPoints() async {
    loadPointsFromJson().run().then((result) {
      result.match(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        ),
        (points) {
          setState(() {
            _availablePoints = points;
          });
        },
      );
    });
  }

  void _updateRouteProgress(LatLng userPos) {
    if (_currentRouteIndex >= _routePoints.length - 1) return;

    const double threshold = 8.0; // metri di tolleranza

    final distance = Geolocator.distanceBetween(
      userPos.latitude,
      userPos.longitude,
      _routePoints[_currentRouteIndex].latitude,
      _routePoints[_currentRouteIndex].longitude,
    );

    if (distance < threshold) {
      // L'utente ha raggiunto il prossimo punto del percorso
      setState(() {
        _currentRouteIndex++;
        _routePoints = _routePoints.sublist(_currentRouteIndex);
      });
    }
  }

  void _startLocationTracking() async {
    final hasPermission = await LocationService.requestLocationPermission();
    if (!hasPermission) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1, 
      ),
    ).listen((Position position) {
      final userPos = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLocation = userPos;
        _heading = position.heading;
      });

      _mapController.move(_userLocation!, _mapController.camera.zoom);

      if (_isItineraryActive && _routePoints.isNotEmpty) {
        _updateRouteProgress(userPos);
        _checkReachedPoints();
        _checkRouteDeviation(userPos);
      }
    });
  }

  Future<void> _buildRoute() async {
    if (_selectedPoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleziona almeno 2 punti")),
      );
      return;
    }

    final points = _selectedPoints.map((p) => p.position).toList();

    try {
      points.insert(0, _userLocation!);
      final route = await RouteService.getRoute(points, profile: _selectedProfile);
      setState(() {
        _routePoints = route;
        _isItineraryActive = true;
        _currentRouteIndex = 0;
      });
      _mapController.move(points.first, 14);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore percorso: $e")),
      );
    }
  }

  void _resetItinerary() {
    setState(() {
      _isItineraryActive = false;
      _selectedPoints = [];
      _markers = [];
      _routePoints = [];
      _currentRouteIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Itinerario terminato.")),
    );
  }

  Future<void> _recalculateRoute() async {
    if (_selectedPoints.isEmpty || !_isItineraryActive || _userLocation == null) return;

    final points = _selectedPoints.map((p) => p.position).toList();

    try {
      // Inseriamo sempre la posizione attuale come punto di partenza
      points.insert(0, _userLocation!);
      final route = await RouteService.getRoute(points);
      setState(() {
        _routePoints = route;
        _currentRouteIndex = 0; // reset progress
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore nel ricalcolo del percorso: $e")),
      );
    }
  }

  void _showTransportModeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return TransportModeDialog(
          onWalkingSelected: () {
            setState(() {
              _selectedProfile = "foot-walking";
            });
            _buildRoute();
          },
          onCyclingSelected: () {
            setState(() {
              _selectedProfile = "cycling-regular";
            });
            _buildRoute();
          },
        );
      },
    );
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers = addPointOfInterest(_markers, position);
    });
  }

  Future<void> _checkReachedPoints() async {
    if (_userLocation == null || !_isItineraryActive) return;

    const threshold = 20.0; // metri

    final reached = _selectedPoints.where((point) {
      final distance = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        point.position.latitude,
        point.position.longitude,
      );
      return distance < threshold;
    }).toList();

    if (reached.isEmpty) return;

    final email = getUserEmail();
    if (email == null) return;

    for (final point in reached) {
      await giveXp(
        service: AppServices.userService,
        email: email,
        xp: 50,
        context: context,
      );

      await giveFlamingo(
        service: AppServices.userService,
        email: email,
        qty: 50,
        context: context,
      );

      await showDialog(
        context: context, 
        builder: (context) => ModalCard(xp: 50, flamingo: 50)
      );
    }

    setState(() {
      _selectedPoints = List.unmodifiable(
        _selectedPoints.where((p) => !reached.contains(p)),
      );
      _markers = List.unmodifiable(
        _markers.where((p) => !reached.map((r) => r.position).contains(p.position)),
      );
    });
    await _recalculateRoute();

    if(_selectedPoints.isEmpty) {
      _resetItinerary();
    }
  }

  void _checkRouteDeviation(LatLng userPos) {
    const deviationThreshold = 10.0; // 10 metri top, ma su tante richieste mmm, magari 15-20 metri potrebbe essere giusto

    final isFar = _routePoints.any((point) {
      final distance = Geolocator.distanceBetween(
        userPos.latitude,
        userPos.longitude,
        point.latitude,
        point.longitude,
      );
      return distance < deviationThreshold;
    });

    if (!isFar) {
      debugPrint("Utente fuori rotta, ricalcolo...");
      _recalculateRoute();
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: SizedBox(
              key: ValueKey<bool>(_isMapExpanded),
              height: _isMapExpanded
                  ? MediaQuery.of(context).size.height
                  : 300,
              width: _isMapExpanded
                  ? MediaQuery.of(context).size.width
                  : double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isMapExpanded ? 0 : 8.0),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(44.014144673845216, 12.637168847679812),
                    initialZoom: 13.0,
                    onLongPress: (tapPosition, latlng) {
                      setState(() {
                        _isMapExpanded = !_isMapExpanded;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                      userAgentPackageName: 'it.discover.discover',
                    ),
                    // itinerary
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5.0,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            width: 50.0,
                            height: 50.0,
                            child: const UserDot()
                          ),
                        ..._markers.map(
                          (p) => Marker(
                            point: p.position,
                            width: 40.0,
                            height: 40.0,
                            child: const Icon(Icons.location_on,
                                color: Colors.red, size: 40.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: const Text(
                    "Punti di Interesse",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              SizedBox(
                height: 200,
                child: _availablePoints.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _availablePoints.length,
                        itemBuilder: (context, index) {
                          final point = _availablePoints[index];
                          final isSelected = _selectedPoints.contains(point);
                          return AbsorbPointer( 
                            absorbing: _isItineraryActive,
                            child: Opacity(
                              opacity: _isItineraryActive ? 0.4 : 1.0,
                              child: PointCard(
                                point: point,
                                selected: isSelected,
                                onSelected: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedPoints = List.unmodifiable([..._selectedPoints, point]);
                                      _markers = addPointOfInterest(_markers, point.position);
                                    } else {
                                      _selectedPoints = List.unmodifiable(
                                        _selectedPoints.where((p) => p != point),
                                      );
                                      _markers = List.unmodifiable(
                                        _markers.where((p) => p.position != point.position),
                                      );
                                    }
                                  });
                                  _mapController.move(point.position, _mapController.camera.zoom);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_isItineraryActive) {
                    _resetItinerary();
                  } else {
                    _showTransportModeDialog();
                  }
                },
                icon: Icon(_isItineraryActive ? Icons.stop : Icons.directions),
                label: Text(_isItineraryActive ? "Finisci Itinerario" : "Inizia Itinerario"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}