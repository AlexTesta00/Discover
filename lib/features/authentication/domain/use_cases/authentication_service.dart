import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationService {
  final SupabaseClient _supbase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(String email, String password) async =>
    await _supbase.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async =>
    await _supbase.auth.signUp(email: email, password: password);

  Future<void> signOut() async => await _supbase.auth.signOut();

  String? getUserEmail() {
    final session = _supbase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}