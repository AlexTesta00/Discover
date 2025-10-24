import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:latlong2/latlong.dart';

const poisRiccione = <PredefinedPoi>[
  PredefinedPoi(
    id: 'aquafan',
    name: 'Aquafan Riccione',
    position: LatLng(43.9996, 12.6547),
    imageAsset: 'assets/characters/airone.png',
  ),
  PredefinedPoi(
    id: 'porto',
    name: 'Porto di Riccione',
    position: LatLng(44.0019, 12.6676),
    imageAsset: 'assets/characters/airone.png',
  ),
  PredefinedPoi(
    id: 'ceccarini',
    name: 'Viale Ceccarini',
    position: LatLng(43.9992, 12.6563),
    imageAsset: 'assets/characters/airone.png',
  ),
];
