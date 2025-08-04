import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/domain/use_cases/build_itinerary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();
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