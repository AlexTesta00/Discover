import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ErrorMessage = String;
final SupabaseClient _supabase = Supabase.instance.client;

const String _profilesTable = 'user_profiles';
TaskEither<ErrorMessage, AuthResponse> signUpAndCreateProfile({
  required String email,
  required String password,
  required String avatarUrl,
}) {
  return TaskEither.tryCatch(() async {
    final res = await _supabase.auth.signUp(email: email, password: password);
    final user = res.user ?? _supabase.auth.currentUser;

    if (user != null) {
      await _supabase.from('user_profiles').upsert({
        'user_id': user.id,
        'email': email,
        'avatar_url': avatarUrl,
      });
    }

    return res;
  }, (error, _) => _mapError(error));
}

TaskEither<ErrorMessage, AuthResponse> signInWithEmailPassword(
  String email,
  String password,
) {
  return TaskEither.tryCatch(
    () => _supabase.auth.signInWithPassword(email: email, password: password),
    (error, _) => _mapError(error),
  );
}

TaskEither<ErrorMessage, AuthResponse> signUpWithEmailPassword(
  String email,
  String password,
) {
  return TaskEither.tryCatch(
    () => _supabase.auth.signUp(email: email, password: password),
    (error, _) => _mapError(error),
  );
}

TaskEither<ErrorMessage, void> signOut() {
  return TaskEither.tryCatch(
    () => _supabase.auth.signOut(),
    (error, _) => _mapError(error),
  );
}

TaskEither<ErrorMessage, AuthResponse> signInWithGoogle(
  String idToken,
  String accessToken,
) {
  return TaskEither.tryCatch(
    () => _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    ),
    (error, _) => _mapError(error),
  );
}

TaskEither<String, Unit> ensureProfileFromCurrentUser() {
  return TaskEither.tryCatch(() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('Non autenticato');

    final existing = await _supabase
        .from(_profilesTable)
        .select('user_id')
        .eq('user_id', user.id)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from(_profilesTable).upsert({
        'user_id': user.id,
        'email': user.email,
      }, onConflict: 'user_id');
    }
    return unit;
  }, (e, _) => _mapError(e));
}

String _mapError(Object error) {
  if (error is AuthException) return error.message;
  if (error is PostgrestException) return error.message;
  return 'Errore inatteso: $error';
}