import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ErrorMessage = String;
final SupabaseClient _supabase = Supabase.instance.client;

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

TaskEither<String, Unit> ensureProfileFromCurrentUser({
  required String defaultAvatarUrl,
}) {
  final _supabase = Supabase.instance.client;
  return TaskEither.tryCatch(() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw const AuthException('Non autenticato');

    final existing = await _supabase
        .from('profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'avatar_url': defaultAvatarUrl,
      });
    }
    return unit;
  }, (e, _) => e is AuthException ? e.message : e is PostgrestException ? e.message : 'Errore inatteso: $e');
}


String? getUserEmail() {
  final session = _supabase.auth.currentSession;
  final user = session?.user;
  return user?.email;
}

Future<String?> getUserAvatar() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final res = await _supabase
      .from('profiles')
      .select('avatar_url')
      .eq('id', user.id)
      .maybeSingle();

  return res?['avatar_url'] as String?;
}

String _mapError(Object error) {
  if (error is AuthException) return error.message;
  return 'Errore inatteso: $error';
}
