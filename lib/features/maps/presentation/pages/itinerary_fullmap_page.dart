import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/use_cases/parks/geo_json_loader.dart';
import '../../domain/use_cases/location_service.dart';
import '../widgets/user_marker.dart';

class ItineraryFullMapPage extends StatefulWidget {
  const ItineraryFullMapPage({
    super.key,
    required this.name,
    required this.assetPath,
    required this.color,
  });

  final String name;
  final String assetPath;
  final Color color;

  @override
  State<ItineraryFullMapPage> createState() => _ItineraryFullMapPageState();
}

class _ItineraryFullMapPageState extends State<ItineraryFullMapPage> {
  final _mapController = MapController();

  List<Polyline>? _polylines;
  List<Polygon>? _polygons;
  LatLng? _userLatLng;
  StreamSubscription<LatLng>? _locationSub;

  @override
  void initState() {
    super.initState();
    _loadRoute();
    _startLocation();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  Future<void> _loadRoute() async {
    final results = await Future.wait([
      loadGeoJsonPolylines(widget.assetPath, color: widget.color, strokeWidth: 4.0),
      loadGeoJsonPolygons(
        widget.assetPath,
        fillColor: widget.color.withValues(alpha: 0.2),
        borderColor: widget.color,
        borderWidth: 2.0,
      ),
    ]);
    if (mounted) {
      setState(() {
        _polylines = results[0] as List<Polyline>;
        _polygons = results[1] as List<Polygon>;
      });
    }
  }

  Future<void> _startLocation() async {
    final initial = await LocationService.ensurePermissionAndGetCurrent();
    if (mounted && initial != null) setState(() => _userLatLng = initial);

    _locationSub = LocationService.positionStream(distanceFilterMeters: 5).listen((pos) {
      if (mounted) setState(() => _userLatLng = pos);
    });
  }

  LatLngBounds? _computeBounds() {
    double? minLat, maxLat, minLon, maxLon;
    void expand(LatLng pt) {
      minLat = minLat == null || pt.latitude < minLat! ? pt.latitude : minLat;
      maxLat = maxLat == null || pt.latitude > maxLat! ? pt.latitude : maxLat;
      minLon = minLon == null || pt.longitude < minLon! ? pt.longitude : minLon;
      maxLon = maxLon == null || pt.longitude > maxLon! ? pt.longitude : maxLon;
    }
    for (final p in _polylines ?? []) { for (final pt in p.points) { expand(pt); } }
    for (final p in _polygons ?? []) { for (final pt in p.points) { expand(pt); } }
    if (minLat == null) return null;
    return LatLngBounds(LatLng(minLat!, minLon!), LatLng(maxLat!, maxLon!));
  }

  void _centerOnUser() {
    if (_userLatLng != null) _mapController.move(_userLatLng!, _mapController.camera.zoom);
  }

  void _resetNorth() {
    _mapController.rotate(0);
  }

  @override
  Widget build(BuildContext context) {
    final loaded = _polylines != null && _polygons != null;
    final bounds = loaded ? _computeBounds() : null;

    return Scaffold(
      body: Stack(
        children: [
          loaded
              ? FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCameraFit: bounds != null
                        ? CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60))
                        : null,
                    initialCenter: const LatLng(44.4, 12.2),
                    initialZoom: 11,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                      rotationThreshold: 10.0,
                      enableMultiFingerGestureRace: true,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileProvider: NetworkTileProvider(
                        cachingProvider: const DisabledMapCachingProvider(),
                      ),
                      userAgentPackageName: 'it.discover.discover',
                    ),
                    if (_polygons!.isNotEmpty) PolygonLayer(polygons: _polygons!),
                    if (_polylines!.isNotEmpty) PolylineLayer(polylines: _polylines!),
                    if (_userLatLng != null) MarkerLayer(markers: [userMarker(_userLatLng!)]),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),

          // Freccia indietro
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),

          // FAB in basso a destra
          Positioned(
            right: 16,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'fullmap_center',
                    onPressed: _centerOnUser,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 4,
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.small(
                    heroTag: 'fullmap_north',
                    onPressed: _resetNorth,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 4,
                    child: const Icon(Icons.explore),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
