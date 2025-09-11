import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:discover/features/maps/presentation/widgets/user_dot.dart';

class ItineraryMap extends StatelessWidget {
  final MapController mapController;
  final List<LatLng> routePoints;
  final List<LatLng> markers;
  final LatLng? userLocation;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const ItineraryMap({
    super.key,
    required this.mapController,
    required this.routePoints,
    required this.markers,
    required this.userLocation,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        key: ValueKey<bool>(isExpanded),
        height: isExpanded ? MediaQuery.of(context).size.height : 300,
        width: isExpanded ? MediaQuery.of(context).size.width : double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isExpanded ? 0 : 8.0),
          child: FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              initialCenter: LatLng(44.014144673845216, 12.637168847679812),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'it.discover.discover',
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 50.0,
                      height: 50.0,
                      child: const UserDot(),
                    ),
                  ...markers.map(
                    (p) => Marker(
                      point: p,
                      width: 40.0,
                      height: 40.0,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ),
                ],
              ),
              // Invisible full-screen detector to toggle expand on long press
              Positioned.fill(
                child: GestureDetector(
                  onLongPress: onToggleExpand,
                  behavior: HitTestBehavior.opaque,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
