import 'package:discover/features/gamification/domain/entities/collectible.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollectiblesService {
  CollectiblesService(this._sb);
  final SupabaseClient _sb;

  /// Prova ad assegnare il collezionabile del personaggio se tutte le challenge sono completate.
  /// Ritorna true se assegnato ora, false altrimenti (già assegnato / non tutte completate / nessuno definito).
  Future<bool> awardIfCompleted(String characterId) async {
    final res = await _sb.rpc('award_collectible_if_completed', params: {
      'p_character_id': characterId,
    });
    return (res as bool?) ?? false;
  }

  // I miei collezionabili
  Future<List<Collectible>> listMyCollectibles() async {
    final res = await _sb.rpc('list_my_collectibles');
    final rows = (res as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return rows.map(Collectible.fromMyMap).toList();
  }

  // Collezionabili mancanti (per i personaggi che hanno uno sticker definito)
  Future<List<Collectible>> listMissingCollectibles() async {
    final res = await _sb.rpc('list_missing_collectibles');
    final rows = (res as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return rows.map(Collectible.fromMissingMap).toList();
  }
}
