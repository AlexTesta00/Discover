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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final polylines = await loadGeoJsonPolylines(
      widget.assetPath,
      color: widget.color,
      strokeWidth: 4.0,
    );
    if (mounted) setState(() => _polylines = polylines);
  }

  LatLngBounds? _computeBounds(List<Polyline> polylines) {
    double? minLat, maxLat, minLon, maxLon;
    for (final p in polylines) {
      for (final pt in p.points) {
        minLat = minLat == null || pt.latitude < minLat ? pt.latitude : minLat;
        maxLat = maxLat == null || pt.latitude > maxLat ? pt.latitude : maxLat;
        minLon = minLon == null || pt.longitude < minLon ? pt.longitude : minLon;
        maxLon = maxLon == null || pt.longitude > maxLon ? pt.longitude : maxLon;
      }
    }
    if (minLat == null) return null;
    return LatLngBounds(LatLng(minLat, minLon!), LatLng(maxLat!, maxLon!));
  }

  @override
  Widget build(BuildContext context) {
    final polylines = _polylines;
    final bounds = polylines != null ? _computeBounds(polylines) : null;

    return Scaffold(
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
            child: polylines == null
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
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        tileProvider: NetworkTileProvider(
                          cachingProvider: const DisabledMapCachingProvider(),
                        ),
                        userAgentPackageName: 'it.discover.discover',
                      ),
                      PolylineLayer(polylines: polylines),
                    ],
                  ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Descrizione dell\'itinerario in arrivo...',
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
