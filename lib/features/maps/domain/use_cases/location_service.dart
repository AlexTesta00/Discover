import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  /// Verifica servizi abilitati, chiede permessi se necessario e ritorna la posizione corrente.
  static Future<LatLng?> ensurePermissionAndGetCurrent() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Servizi posizione disabilitati: non chiediamo permesso, ritorniamo null
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return null;
    }

    final pos = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.best,
    );

    return LatLng(pos.latitude, pos.longitude);
  }

  /// Stream di aggiornamenti della posizione (per seguire l’utente).
  static Stream<LatLng> positionStream({
    LocationAccuracy accuracy = LocationAccuracy.best,
    int distanceFilterMeters = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
      ),
    ).map((p) => LatLng(p.latitude, p.longitude));
  }
}