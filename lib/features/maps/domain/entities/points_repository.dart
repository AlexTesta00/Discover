import 'package:discover/features/maps/domain/entities/point_of_interest.dart';

abstract class PointsRepository {
  Future<List<PointOfInterest>> loadAvailable();
}