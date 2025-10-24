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

  // POI + callback selezione
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
        // ricreamo le polylines applicando il colore del tema
        final themedPolylines = mapUtils.polylines
            .map((poly) => Polyline(
                  points: poly.points,
                  strokeWidth: 5,
                  color: Theme.of(context).primaryColor,
                ))
            .toList();

        final markers = <Marker>[
          // Marker dei POI con icona da imageAsset
          ...pois.map((poi) => Marker(
                point: poi.position,
                width: 52,
                height: 52,
                child: GestureDetector(
                  onTap: () => onPoiTap?.call(poi),
                  child: _poiMarker(context, poi),
                ),
              )),
          // Marker utente
          if (userLatLng != null) userMarker(userLatLng!),
        ];

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            // nessun onLongPress/onTap: i punti sono predefiniti
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

  Widget _poiMarker(BuildContext context, PredefinedPoi poi) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primary, width: 2),
        boxShadow: const [
          BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Colors.black26),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: poi.imageAsset != null
          ? Image.asset(poi.imageAsset!, fit: BoxFit.cover)
          : Icon(Icons.place, size: 28, color: primary),
    );
  }
}
