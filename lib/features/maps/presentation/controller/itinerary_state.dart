import 'package:discover/features/maps/domain/entities/location_tracker.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:latlong2/latlong.dart';


class ItineraryState {
  final List<PointOfInterest> availablePoints;
  final List<PointOfInterest> selectedPoints;
  final List<PointOfInterest> markers;
  final List<LatLng> routePoints;
  final UserPose? userPose;
  final bool isMapExpanded;
  final bool isItineraryActive;
  final int currentRouteIndex;
  final String selectedProfile;


  const ItineraryState({
  this.availablePoints = const [],
  this.selectedPoints = const [],
  this.markers = const [],
  this.routePoints = const [],
  this.userPose,
  this.isMapExpanded = false,
  this.isItineraryActive = false,
  this.currentRouteIndex = 0,
  this.selectedProfile = 'foot-walking',
  });


  ItineraryState copyWith({
    List<PointOfInterest>? availablePoints,
    List<PointOfInterest>? selectedPoints,
    List<PointOfInterest>? markers,
    List<LatLng>? routePoints,
    UserPose? userPose,
    bool? isMapExpanded,
    bool? isItineraryActive,
    int? currentRouteIndex,
    String? selectedProfile,
  }) => ItineraryState(
    availablePoints: availablePoints ?? this.availablePoints,
    selectedPoints: selectedPoints ?? this.selectedPoints,
    markers: markers ?? this.markers,
    routePoints: routePoints ?? this.routePoints,
    userPose: userPose ?? this.userPose,
    isMapExpanded: isMapExpanded ?? this.isMapExpanded,
    isItineraryActive: isItineraryActive ?? this.isItineraryActive,
    currentRouteIndex: currentRouteIndex ?? this.currentRouteIndex,
    selectedProfile: selectedProfile ?? this.selectedProfile,
  );
}