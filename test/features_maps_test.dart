import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/domain/use_cases/build_itinerary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  group('buildItineraryUrl', () {
    test('should return error if points list is empty', () {
      final result = buildItineraryUrl([]);
      expect(result.isLeft(), true);
      expect(result.swap().getOrElse((_) => ''), "Aggiungi almeno due marker per iniziare l'itinerario");
    });

    test('should return error if points list has less than 2 elements', () {
      final result = buildItineraryUrl([LatLng(44.0, 12.6)]);
      expect(result.isLeft(), true);
      expect(result.swap().getOrElse((_) => ''), "Aggiungi almeno due marker per iniziare l'itinerario");
    });

    test('should return URL with origin and destination for 2 points', () {
      final points = [
        LatLng(44.0, 12.6),
        LatLng(44.1, 12.7),
      ];
      final result = buildItineraryUrl(points);
      expect(result.isRight(), true);
      result.match(
        (_) {},
        (url) {
          expect(url.contains("origin=44.0,12.6"), true);
          expect(url.contains("destination=44.1,12.7"), true);
          expect(url.contains("waypoints="), false);
          expect(url.contains("travelmode=walking"), true);
        },
      );
    });

    test('should include waypoints in URL when more than 2 points', () {
      final points = [
        LatLng(44.0, 12.6),
        LatLng(44.05, 12.65),
        LatLng(44.1, 12.7),
      ];
      final result = buildItineraryUrl(points);
      expect(result.isRight(), true);
      result.match(
        (_) {},
        (url) {
          expect(url.contains("waypoints=44.05,12.65"), true);
        },
      );
    });
  });

  group('getFarthestPoint', () {
    test('should return the farthest point from the origin', () {
      final origin = LatLng(44.0, 12.6);
      final points = [
        LatLng(44.01, 12.61),
        LatLng(44.2, 12.9), // più lontano
        LatLng(44.05, 12.65),
      ];

      final farthest = getFarthestPoint(origin, points);
      expect(farthest, LatLng(44.2, 12.9));
    });

    test('should return the origin if points list has only one element', () {
      final origin = LatLng(44.0, 12.6);
      final points = [LatLng(44.0, 12.6)];
      final farthest = getFarthestPoint(origin, points);
      expect(farthest, origin);
    });
  });

    group('addPointOfInterest', () {
    test('should add new PointOfInterest to the list', () {
      final initial = <PointOfInterest>[];
      final position = LatLng(44.0, 12.6);
      final updated = addPointOfInterest(initial, position);

      expect(updated.length, 1);
      expect(updated.first.position, position);
    });

    test('should not mutate the original list', () {
      final initial = <PointOfInterest>[];
      final updated = addPointOfInterest(initial, LatLng(44.0, 12.6));
      expect(identical(initial, updated), false);
      expect(initial.isEmpty, true);
    });
  });

}