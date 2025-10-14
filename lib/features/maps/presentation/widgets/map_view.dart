import 'package:discover/features/maps/domain/use_cases/map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'user_marker.dart';

class MapView extends StatelessWidget {
  final MapController mapController;
  final MapService mapUtils;
  final LatLng initialCenter;
  final LatLng? userLatLng;

  final void Function(LatLng)? onLongPressAddPoint;
  final void Function(LatLng)? onTapRemoveNear;

  const MapView({
    super.key,
    required this.mapController,
    required this.mapUtils,
    required this.initialCenter,
    this.userLatLng,
    this.onLongPressAddPoint,
    this.onTapRemoveNear,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mapUtils,
      builder: (context, _) {
        final markers = <Marker>[
          ...mapUtils.markers,
          if (userLatLng != null) userMarker(userLatLng!),
        ];

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onLongPress: (_, p) => onLongPressAddPoint?.call(p),
            onTap: (_, p) => onTapRemoveNear?.call(p),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              tileProvider: NetworkTileProvider(
                cachingProvider: const DisabledMapCachingProvider(),
              ),
              userAgentPackageName: 'it.discover.discover',
            ),
            PolylineLayer(
              polylines: mapUtils.polylines
                  .map(
                    (p) => Polyline(
                      points: p.points,
                      strokeWidth: 5,
                      color: Theme.of(
                        context,
                      ).primaryColor,
                    ),
                  )
                  .toList(),
            ),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}
