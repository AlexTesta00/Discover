import 'package:shared_preferences/shared_preferences.dart';
import 'package:discover/features/gamification/domain/entities/user.dart';

class UserRepository {

  Future<User?> fetch(String email) async {
    _ensureEmail(email);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(email);
    if (raw == null) return null;
    try {
      return User.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  Future<User> getOrCreate({
    String? email,
    String? Function()? emailProvider,
  }) async {
    final resolvedEmail = email ?? (emailProvider?.call() ?? '').trim();
    _ensureEmail(resolvedEmail);

    final existing = await fetch(resolvedEmail);
    if (existing != null) return existing;

    final created = User(email: resolvedEmail);
    await save(created);
    return created;
  }

  Future<void> save(User user) async {
    _ensureEmail(user.email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(user.email, user.toJsonString());
  }

  Future<User> update(String email, User Function(User user) updater) async {
    _ensureEmail(email);
    final current = await getOrCreate(email: email);
    final updated = updater(current);
    await save(updated);
    return updated;
  }

  Future<void> clear(String email) async {
    _ensureEmail(email);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(email);
  }

  void _ensureEmail(String email) {
    if (email.isEmpty) {
      throw ArgumentError('Email non può essere vuota.');
    }
  }
}
