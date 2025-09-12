import 'dart:async';
import 'package:discover/features/maps/domain/entities/location_tracker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';


class GeolocatorLocationTracker implements LocationTracker {
  StreamSubscription<Position>? _sub;


  @override
  Stream<UserPose> poseStream({int distanceFilterMeters = 1}) async* {
      final stream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: distanceFilterMeters,
      ),
    );
    await for (final p in stream) {
      yield UserPose(position: LatLng(p.latitude, p.longitude), heading: p.heading);
    }
  }


  @override
  Future<UserPose> currentPose() async {
    final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return UserPose(position: LatLng(p.latitude, p.longitude), heading: p.heading);
  }


  @override
  Future<bool> ensureReady({Future<void> Function()? openLocationSettings, Future<void> Function()? openAppSettings}) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (openLocationSettings != null) await openLocationSettings();
      return false;
   }


  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied) {
    return false;
  }


  if (permission == LocationPermission.deniedForever) {
    if (openAppSettings != null) await openAppSettings();
    return false;
  }
    return true;
  }
}