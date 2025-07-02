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

TaskEither<ErrorMessage, AuthResponse> signInWithGoogle (String idToken, String accessToken) {
  return TaskEither.tryCatch(
    () => _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google, 
      idToken: idToken,
      accessToken: accessToken,
      ),
    (error, _) => _mapError(error),
  );
}

String? getUserEmail() {
  final session = _supabase.auth.currentSession;
  final user = session?.user;
  return user?.email;
}

String _mapError(Object error) {
  if (error is AuthException) return error.message;
  return 'Errore inatteso: $error';
}