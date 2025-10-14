import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/use_cases/map_service.dart';
import 'user_marker.dart';

class MapView extends StatelessWidget {
  final MapController mapController;
  final MapService mapUtils;
  final LatLng initialCenter;
  final LatLng? userLatLng;
  final List<PredefinedPoi> pois;
  final void Function(PredefinedPoi)? onPoiTap;

  const MapView({
    super.key,
    required this.mapController,
    required this.mapUtils,
    required this.initialCenter,
    required this.pois,
    this.userLatLng,
    this.onPoiTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mapUtils,
      builder: (context, _) {
        final markers = <Marker>[
          // POI markers
          ...pois.map((poi) => Marker(
                point: poi.position,
                width: 44,
                height: 44,
                child: GestureDetector(
                  onTap: () => onPoiTap?.call(poi),
                  child: _poiMarker(context),
                ),
              )),
          // Utente
          if (userLatLng != null) userMarker(userLatLng!),
        ];

        // Coloriamo le polylines col primaryColor
        final themedPolylines = mapUtils.polylines
            .map((poly) => Polyline(
                  points: poly.points,
                  strokeWidth: 5,
                  color: Theme.of(context).primaryColor,
                ))
            .toList();

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            // Niente onLongPress/onTap: l’utente non crea/rimuove punti
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              tileProvider: NetworkTileProvider(
                cachingProvider: const DisabledMapCachingProvider()
              ),
              userAgentPackageName: 'it.discover.discover',
            ),
            PolylineLayer(polylines: themedPolylines),
            MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }

  Widget _poiMarker(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withOpacity(0.15),
        border: Border.all(color: primary, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Colors.black26)],
      ),
      child: const Center(child: Icon(Icons.place, size: 22)),
    );
  }
}
