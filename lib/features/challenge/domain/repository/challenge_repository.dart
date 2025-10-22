import 'dart:io';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeRepository {
  final SupabaseClient client;

  ChallengeRepository(this.client);

  /// Tutte le challenge NON ancora completate dall’utente loggato (via RPC)
  Future<List<Challenge>> getOpenChallenges() async {
    final response = await client.rpc('get_user_open_challenges').select();
    final List data = response as List;
    return data
        .map((e) => Challenge.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Tutte le challenge completate dall’utente loggato (via RPC)
  Future<List<Challenge>> getCompletedChallenges() async {
    final response = await client.rpc('get_user_completed_challenges').select();
    final List data = response as List;
    return data
        .map((e) => Challenge.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Invia una submission con eventuale foto
  Future<String> submitChallenge({
    required String challengeId,
    File? photoFile,
    Map<String, dynamic>? photoMeta,
    String note = '',
  }) async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Utente non autenticato');
    }

    final email = user.email!;
    String? photoPath;

    // Upload foto se presente
    if (photoFile != null) {
      final ext = photoFile.path.split('.').last;
      final filename = const Uuid().v4();
      photoPath = '$email/$challengeId/$filename.$ext';

      await client.storage
          .from('challenge-submissions')
          .upload(photoPath, photoFile);
    }

    final insertResponse = await client
        .from('challenge_submissions')
        .insert({
          'user_email': email,
          'challenge_id': challengeId,
          'note': note.isNotEmpty ? note : null,
          'photo_path': photoPath,
          'photo_meta': photoMeta ?? {},
        })
        .select()
        .single();

    return insertResponse['id'] as String;
  }

  Future<List<Challenge>> fetchAllWithCharacter() async {
    final rows = await client
        .from('challenges')
        .select('''
          id, character_id, title, description, labels, xp, fenicotteri,
          requires_photo, is_active, start_at, end_at, created_at, updated_at,
          character:characters (
            id, name, image_asset, story, lat, lng
          )
        ''')
        .order('start_at', ascending: true, nullsFirst: true)
        .order('created_at', ascending: false);

    final list = (rows as List).cast<Map<String, dynamic>>();
    return list.map(Challenge.fromMap).toList();
  }

  /// Set degli ID challenge completate (usa RPC che filtra su auth.email()).
  Future<Set<String>> fetchCompletedIds() async {
    final rows = await client.rpc('get_user_completed_challenges').select();
    final list = (rows as List).cast<Map<String, dynamic>>();
    return list.map((m) => m['id'] as String).toSet();
  }
}
