import 'package:discover/features/authentication/data/models/profile.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ErrorMessage = String;
final SupabaseClient _supabase = Supabase.instance.client;
const String _profilesTable = 'profiles';

String _mapError(Object error) {
  if (error is AuthException) return error.message;
  if (error is PostgrestException) return error.message;
  return 'Errore inatteso: $error';
}

TaskEither<ErrorMessage, AuthResponse> signUpAndCreateProfile({
  required String email,
  required String password,
  required String avatarUrl,
}) {
  return TaskEither.tryCatch(() async {
    final res = await _supabase.auth.signUp(email: email, password: password);

    final user = res.user ?? _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.from(_profilesTable).upsert({
        'id': user.id,
        'email': email,
        'avatar_url': avatarUrl,
      });
    }
    return res;
  }, (error, _) => _mapError(error));
}

TaskEither<ErrorMessage, Unit> ensureMyProfile({
  required String email,
  String? avatarUrl,
}) {
  return TaskEither.tryCatch(() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthException('Utente non autenticato');
    }

    await _supabase.from(_profilesTable).upsert({
      'id': user.id,
      'email': email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    });

    return unit;
  }, (error, _) => _mapError(error));
}

TaskEither<ErrorMessage, Unit> updateMyProfile({
  String? email,
  String? avatarUrl,
}) {
  return TaskEither.tryCatch(() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw AuthException('Utente non autenticato');
    }

    final updates = <String, dynamic>{};
    if (email != null) updates['email'] = email;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isEmpty) return unit;

    await _supabase.from(_profilesTable).update(updates).eq('id', user.id);
    return unit;
  }, (error, _) => _mapError(error));
}

TaskEither<ErrorMessage, Profile?> fetchProfileById(String userId) {
  return TaskEither.tryCatch(() async {
    final data = await _supabase
        .from(_profilesTable)
        .select('id, email, avatar_url, updated_at')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromMap(data);
  }, (error, _) => _mapError(error));
}
