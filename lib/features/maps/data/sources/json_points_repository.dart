import 'package:discover/features/maps/data/sources/point_of_interest_remote_data_source.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/domain/entities/points_repository.dart';


class JsonPointsRepository implements PointsRepository {
  @override
    Future<List<PointOfInterest>> loadAvailable() async {
    final result = await loadPointsFromStorage().run();
    return result.match((err) => throw Exception(err), (points) => points);
  }
}