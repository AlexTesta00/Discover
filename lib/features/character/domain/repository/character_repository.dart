import 'package:discover/features/character/domain/entities/character.dart';
import 'package:discover/features/character/domain/use_cases/character_service.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';

class CharactersRepository {
  CharactersRepository(this.api);
  final CharactersApi api;

  Future<List<PredefinedPoi>> getCharacterPois() async {
    final chars = await api.getAllCharacters();
    return chars.map((c) => c.toPoi()).toList();
  }
}
