import 'package:discover/features/maps/data/itinerary_descriptions.dart';
import 'package:discover/features/maps/data/itinerary_fauna.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/use_cases/parks/geo_json_loader.dart';

class ItineraryDetailPage extends StatefulWidget {
  const ItineraryDetailPage({
    super.key,
    required this.name,
    required this.assetPath,
    required this.color,
  });

  final String name;
  final String assetPath;
  final Color color;

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage> {
  List<Polyline>? _polylines;
  List<Polygon>? _polygons;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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

  LatLngBounds? _computeBounds() {
    double? minLat, maxLat, minLon, maxLon;

    void expand(LatLng pt) {
      minLat = minLat == null || pt.latitude < minLat! ? pt.latitude : minLat;
      maxLat = maxLat == null || pt.latitude > maxLat! ? pt.latitude : maxLat;
      minLon = minLon == null || pt.longitude < minLon! ? pt.longitude : minLon;
      maxLon = maxLon == null || pt.longitude > maxLon! ? pt.longitude : maxLon;
    }

    for (final p in _polylines ?? []) {
      for (final pt in p.points) { expand(pt); }
    }
    for (final p in _polygons ?? []) {
      for (final pt in p.points) { expand(pt); }
    }

    if (minLat == null) return null;
    return LatLngBounds(LatLng(minLat!, minLon!), LatLng(maxLat!, maxLon!));
  }

  @override
  Widget build(BuildContext context) {
    final loaded = _polylines != null && _polygons != null;
    final bounds = loaded ? _computeBounds() : null;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            widget.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 300,
              child: !loaded
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      options: MapOptions(
                        initialCameraFit: bounds != null
                            ? CameraFit.bounds(
                                bounds: bounds,
                                padding: const EdgeInsets.all(40),
                              )
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
                      ],
                    ),
            ),
            TabBar(
              indicatorColor: widget.color,
              labelColor: widget.color,
              unselectedLabelColor: Colors.black54,
              tabs: const [
                Tab(text: 'Descrizione'),
                Tab(text: 'Fauna'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _DescriptionBody(assetPath: widget.assetPath),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _FaunaBody(assetPath: widget.assetPath),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionBody extends StatelessWidget {
  const _DescriptionBody({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final stem = assetPath.split('/').last.replaceAll('.geojson', '');
    final sections = itineraryDescriptions[stem];

    if (sections == null || sections.isEmpty) {
      return const Text(
        'Descrizione non disponibile.',
        style: TextStyle(fontSize: 15, color: Colors.black54),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in sections) ...[
          if (s.title != null) ...[
            Text(s.title!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
          ],
          Text(s.body, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _FaunaBody extends StatelessWidget {
  const _FaunaBody({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final stem = assetPath.split('/').last.replaceAll('.geojson', '');
    final animals = itineraryFauna[stem];

    if (animals == null || animals.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 32),
          child: Text(
            'Nessun animale registrato per questo itinerario.',
            style: TextStyle(fontSize: 15, color: Colors.black45),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final animal in animals) ...[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 2), color: Colors.black12)],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.05),
                child: const Icon(Icons.cruelty_free, size: 20, color: Colors.black54),
              ),
              title: Text(animal.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: animal.category != null
                  ? Text(animal.category!, style: const TextStyle(fontSize: 12, color: Colors.black45))
                  : null,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
