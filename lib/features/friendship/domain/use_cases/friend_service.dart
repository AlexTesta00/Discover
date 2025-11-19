import 'package:discover/features/friendship/domain/entities/friend_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';

class FriendService {
  FriendService(this._sb);
  final SupabaseClient _sb;

  /// Invia una richiesta di amicizia all'utente con questa email
  Future<void> sendFriendRequest(String toEmail) async {
    final me = getUserEmail();
    if (me == null) {
      throw Exception('Non autenticato');
    }
    if (toEmail == me) {
      throw Exception('Non puoi mandare una richiesta a te stesso');
    }

    //controlla se siete già amici usando a_email / b_email (ordinati)
    final pair = [me, toEmail]..sort(); // garantisce pair[0] < pair[1]

    final existingFriend = await _sb
        .from('friendships')
        .select('a_email')
        .eq('a_email', pair[0])
        .eq('b_email', pair[1])
        .maybeSingle();

    if (existingFriend != null) {
      throw Exception('Siete già amici');
    }

    //controlla se esiste già una richiesta pendente tra i due (in qualunque verso)
    final pending = await _sb
        .from('friend_requests')
        .select('id')
        .or(
          'and(from_email.eq.$me,to_email.eq.$toEmail,status.eq.pending),'
          'and(from_email.eq.$toEmail,to_email.eq.$me,status.eq.pending)',
        )
        .maybeSingle();

    if (pending != null) {
      throw Exception('Esiste già una richiesta in sospeso');
    }

    //inserisci la richiesta
    await _sb.from('friend_requests').insert({
      'from_email': me,
      'to_email': toEmail,
      // status = 'pending' di default
    });
  }

  /// Richieste ricevute (in arrivo) ancora pendenti
  Future<List<FriendRequest>> getIncomingRequests() async {
    final me = getUserEmail();
    if (me == null) throw Exception('Non autenticato');

    final res = await _sb
        .from('friend_requests')
        .select('''
          id,
          from_email,
          to_email,
          status,
          created_at,
          responded_at,
          from_profile:user_profiles!friend_requests_from_email_fkey (
            avatar_url
          )
        ''')
        .eq('to_email', me)
        .eq('status', 'pending')
        .order('created_at', ascending: true);

    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(FriendRequest.fromMap).toList();
  }

  /// Richieste inviate da me ancora pendenti
  Future<List<FriendRequest>> getOutgoingRequests() async {
    final me = getUserEmail();
    if (me == null) throw Exception('Non autenticato');

    final res = await _sb
        .from('friend_requests')
        .select('*')
        .eq('from_email', me)
        .eq('status', 'pending')
        .order('created_at', ascending: true);

    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(FriendRequest.fromMap).toList();
  }

  /// Accetta una richiesta (chiama la RPC)
  Future<bool> acceptRequest(String requestId) async {
    final res = await _sb.rpc(
      'accept_friend_request',
      params: {'p_request_id': requestId},
    );
    return (res as bool?) ?? false;
  }

  /// Rifiuta una richiesta (solo update di stato)
  Future<void> rejectRequest(String requestId) async {
    final me = getUserEmail();
    if (me == null) throw Exception('Non autenticato');

    await _sb
        .from('friend_requests')
        .update({
          'status': 'rejected',
          'responded_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('to_email', me)
        .eq('status', 'pending');
  }
}
