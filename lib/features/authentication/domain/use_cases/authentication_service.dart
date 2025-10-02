import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef ErrorMessage = String;
final SupabaseClient _supabase = Supabase.instance.client;
const String _profilesTable = 'profiles';
const String _defaultAvatar = 'assets/avatar/avatar_9.png';
const String _defaultBackground = 'assets/background/default.png';

TaskEither<ErrorMessage, AuthResponse> signUpAndCreateProfile({
  required String email,
  required String password,
  String? avatarUrl,
  String? backgroundUrl,
}) {
  return TaskEither.tryCatch(() async {
    final res = await _supabase.auth.signUp(email: email, password: password);

    final user = res.user ?? _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.from(_profilesTable).upsert({
        'id': user.id,
        'email': email,
        'avatar_url': avatarUrl ?? _defaultAvatar,
        'background_url': backgroundUrl ?? _defaultBackground,
        'xp': 0,
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

TaskEither<String, Unit> ensureProfileFromCurrentUser({
  required String defaultAvatarUrl,
  required String defaultBackgroundUrl,
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
        'background_url': defaultBackgroundUrl,
        'xp': 0,
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

Future<String?> getUserBackground() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final res = await _supabase
      .from('profiles')
      .select('background_url')
      .eq('id', user.id)
      .maybeSingle();

  return res?['background_url'] as String?;
}

String _mapError(Object error) {
  if (error is AuthException) return error.message;
  if (error is PostgrestException) return error.message;
  return 'Errore inatteso: $error';
}
