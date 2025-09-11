import 'package:latlong2/latlong.dart';

class UserPose {
  final LatLng position;
  final double heading;
  const UserPose({required this.position, required this.heading});
}

abstract class LocationTracker {
  /// Emits user pose updates (position + heading).
  Stream<UserPose> poseStream({int distanceFilterMeters = 1});

  /// Returns current pose once.
  Future<UserPose> currentPose();

  /// Ensures permissions and services are enabled.
  /// Returns true if location is ready to use.
  Future<bool> ensureReady({Future<void> Function()? openLocationSettings, Future<void> Function()? openAppSettings});
}