import 'dart:io';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/entities/challenge_submission_item.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChallengeRepository {
  final SupabaseClient client;

  ChallengeRepository(this.client);


  /// Recupera le foto challenge pubbliche (pubbliche nel bucket)
  Future<List<String>> getUserChallengePhotoUrls() async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Non autenticato');

    final rows = await client
        .from('challenge_submissions')
        .select('photo_path')
        .eq('user_email', getUserEmail()!)
        .not('photo_path', 'is', null)
        .order('created_at', ascending: false);

    final list = (rows as List).cast<Map<String, dynamic>>();
    final paths = list
        .map((m) => m['photo_path'] as String?)
        .where((p) => p != null && p.isNotEmpty)
        .cast<String>()
        .toList();

    final bucket = client.storage.from('challenge-submissions');
    final urls = <String>[];

    for (final path in paths) {
      final publicUrl = bucket.getPublicUrl(path);
      urls.add(publicUrl);
    }

    return urls;
  }

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

  /// Inserisce SEMPRE una nuova submission (non fa upsert).
  /// Usato quando si vuole poter completare più volte la stessa challenge
  /// salvando ogni foto come riga separata in challenge_submissions.
  Future<String> insertChallengeSubmission({
    required String challengeId,
    File? photoFile,
    Map<String, dynamic>? photoMeta,
    String note = '',
  }) async {
    final user = client.auth.currentUser;
    if (user == null) throw StateError('Utente non autenticato');

    final email = user.email!;
    String? photoPath;

    if (photoFile != null) {
      final ext = photoFile.path.split('.').last.toLowerCase();
      final filename = const Uuid().v4();
      photoPath = '$challengeId/$email/$filename.$ext';
      await client.storage
          .from('challenge-submissions')
          .upload(photoPath, photoFile);
    }

    final inserted = await client
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

    return inserted['id'] as String;
  }

  /// Invia una submission con eventuale foto
  Future<String> submitChallenge({
    required String challengeId,
    File? photoFile,
    Map<String, dynamic>? photoMeta,
    String note = '',
  }) async {
    return insertChallengeSubmission(
      challengeId: challengeId,
      photoFile: photoFile,
      photoMeta: photoMeta,
      note: note,
    );
  }

  // Restituisce le URL PUBBLICHE di tutte le foto challenge per l'utente [email].
  // Scansiona: <challengeId>/<email>/... nel bucket 'challenge-submissions'.
  Future<List<String>> getPublicPhotoUrlsByEmail(String email) async {
    final storage = client.storage.from('challenge-submissions');

    // 1) lista cartelle top-level (challengeId)
    final top = await storage.list(path: '');

    final urls = <String>[];
    for (final folder in top) {
      final challengeId = folder.name; // es. "9b1c-....-uuid"
      if (challengeId.isEmpty) continue;

      // 2) lista i file sotto <challengeId>/<email>
      final subPath = '$challengeId/$email';
      final files = await storage.list(path: subPath);

      for (final f in files) {
        // filtro opzionale per estensioni immagine
        final name = f.name.toLowerCase();
        if (name.endsWith('.jpg') ||
            name.endsWith('.jpeg') ||
            name.endsWith('.png') ||
            name.endsWith('.webp') ||
            name.endsWith('.heic')) {
          final fullPath = '$subPath/${f.name}';
          final publicUrl = storage.getPublicUrl(fullPath);
          urls.add(publicUrl);
        }
      }
    }

    // Ordina per "più recente prima" se hai bisogno: lo Storage non dà timestamp affidabili per cartelle.
    // In assenza di created_at, lasciamo l'ordine naturale (per challenge).
    return urls;
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

  Future<void> onPhotoCaptured({
    required File file,
    required Challenge challenge,
  }) async {
    await submitChallenge(
      challengeId: challenge.id,
      photoFile: file,
      photoMeta: {
        'source': 'camera',
        'character_id': challenge.characterId,
        'challenge_title': challenge.title,
      },
    );
  }

  Future<List<ChallengeSubmissionItem>> getSubmissionsForEmail(
    String email,
  ) async {
    final rows = await client
        .from('challenge_submissions')
        .select(
          'created_at, photo_path, '
          'challenge:challenges(title, requires_photo, character:characters(image_asset))',
        )
        .eq('user_email', email)
        .order('created_at', ascending: false);

    final bucket = client.storage.from('challenge-submissions');
    final list = (rows as List).cast<Map<String, dynamic>>();

    return list.map((m) {
      final challengeMap = m['challenge'] as Map<String, dynamic>?;
      final title = challengeMap?['title'] as String? ?? 'Sfida sconosciuta';
      final requiresPhoto = challengeMap?['requires_photo'] as bool? ?? false;
      final characterMap = challengeMap?['character'] as Map<String, dynamic>?;
      final imageAsset = characterMap?['image_asset'] as String? ?? '';
      final photoPath = m['photo_path'] as String?;
      final photoUrl = (photoPath != null && photoPath.isNotEmpty)
          ? bucket.getPublicUrl(photoPath)
          : null;
      return ChallengeSubmissionItem(
        completedAt: DateTime.parse(m['created_at'] as String).toLocal(),
        challengeTitle: title,
        requiresPhoto: requiresPhoto,
        characterImageAsset: imageAsset,
        photoUrl: photoUrl,
      );
    }).toList();
  }

  Future<(String?, bool)> completeTalkChallengeForCharacter(
    String characterId,
  ) async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Non autenticato');

    final row = await client
        .from('challenges')
        .select('id')
        .eq('character_id', characterId)
        .eq('requires_photo', false)
        .maybeSingle();

    final challengeId = row?['id'] as String?;
    if (challengeId == null) {
      debugPrint(
        'Nessuna challenge di dialogo trovata per personaggio $characterId',
      );
      return (null, false);
    }

    final completedIds = await fetchCompletedIds();
    final wasNew = !completedIds.contains(challengeId);

    final submissionId = await insertChallengeSubmission(
      challengeId: challengeId,
      photoMeta: {
        'source': 'dialogue',
        'character_id': characterId,
      },
    );

    return (submissionId, wasNew);
  }
}
