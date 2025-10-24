import 'package:discover/features/character/domain/entities/character.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _sb = Supabase.instance.client;

class CharactersApi {
  Future<List<Character>> getAllCharacters() async {
    final res = await _sb.rpc('get_all_characters');

    final rows = (res as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return rows.map(Character.fromMap).toList();
  }
}
