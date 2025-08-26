import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:flutter/services.dart' show rootBundle;

class ChallengeRepository {
  static const String _path = 'assets/data/challenge.json';

  Future<List<Challenge>> loadAll() async {
    final jsonStr = await rootBundle.loadString(_path);
    return Challenge.listFromJson(jsonStr);
  }
}
