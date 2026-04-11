import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
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

  final void Function(LatLng)? onLongPressMap;

  const MapView({
    super.key,
    required this.mapController,
    required this.mapUtils,
    required this.initialCenter,
    required this.pois,
    this.userLatLng,
    this.onPoiTap,
    this.onLongPressMap,
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

        final poiMarkers = pois.map((poi) => Marker(
              point: poi.position,
              width: 52,
              height: 52,
              child: GestureDetector(
                onTap: () => onPoiTap?.call(poi),
                child: _poiMarker(context, poi),
              ),
            )).toList();

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13.0,
            minZoom: 6.0,
            maxZoom: 18.0,
            cameraConstraint: CameraConstraint.containCenter(
              bounds: LatLngBounds(
                const LatLng(35.5, 6.6),  // sud-ovest (Sicilia)
                const LatLng(47.1, 18.5), // nord-est (Alpi/Trieste)
              ),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
              rotationThreshold: 10.0,
              enableMultiFingerGestureRace: true,
            ),
            onLongPress: (tapPos, latLng) => onLongPressMap?.call(latLng),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              tileProvider: NetworkTileProvider(
                cachingProvider: const DisabledMapCachingProvider()
              ),
              userAgentPackageName: 'it.discover.discover',
            ),
            PolygonLayer(polygons: mapUtils.polygons),
            PolylineLayer(polylines: themedPolylines),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 80,
                size: const Size(48, 48),
                markers: poiMarkers,
                builder: (context, clusterMarkers) {
                  final primary = Theme.of(context).primaryColor;
                  return Container(
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Colors.black26),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${clusterMarkers.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (userLatLng != null) MarkerLayer(markers: [userMarker(userLatLng!)]),
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
