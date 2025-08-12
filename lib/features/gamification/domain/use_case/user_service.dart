import 'dart:async';
import 'package:discover/features/gamification/domain/entities/user.dart';
import 'package:discover/features/gamification/domain/repository/user_repository.dart';

abstract class UserEvent {
  final String email;
  final DateTime at;
  UserEvent(this.email) : at = DateTime.now();
}

class XpAdded extends UserEvent {
  final int added;
  final int totalXp;
  XpAdded({required String email, required this.added, required this.totalXp})
      : super(email);
}

class FlamingoAdded extends UserEvent {
  final int added;
  final int totalFlamingo;
  FlamingoAdded({required String email, required this.added, required this.totalFlamingo})
      : super(email);
}

class FlamingoRemoved extends UserEvent {
  final int removed;
  final int totalFlamingo;
  FlamingoRemoved({required String email, required this.removed, required this.totalFlamingo})
      : super(email);
}

class LevelUp extends UserEvent {
  final String fromLevelName;
  final String toLevelName;
  LevelUp({
    required String email,
    required this.fromLevelName,
    required this.toLevelName,
  }) : super(email);
}

class UserService {
  final UserRepository _repo;

  final StreamController<UserEvent> _eventsCtrl = StreamController<UserEvent>.broadcast();

  final Map<String, User> _cache = {};

  UserService(this._repo);

  Stream<UserEvent> get events => _eventsCtrl.stream;

  String _resolveEmail({String? email, String? Function()? emailProvider}) {
    final resolved = (email ?? emailProvider?.call() ?? '').trim();
    if (resolved.isEmpty) {
      throw ArgumentError('Email non può essere vuota.');
    }
    return resolved;
  }

  Future<User> getOrCreate({String? email, String? Function()? emailProvider}) async {
    final key = _resolveEmail(email: email, emailProvider: emailProvider);
    final cached = _cache[key];
    if (cached != null) return cached;

    final user = await _repo.getOrCreate(email: key);
    _cache[key] = user;
    return user;
  }

  Future<User?> fetch(String email) async {
    final key = _resolveEmail(email: email);
    final cached = _cache[key];
    if (cached != null) return cached;

    final loaded = await _repo.fetch(key);
    if (loaded != null) _cache[key] = loaded;
    return loaded;
  }

  String getEmail({required String? Function() emailProvider}) {
    final e = (emailProvider() ?? '').trim();
    if (e.isEmpty) {
      throw ArgumentError('Email non può essere vuota dal provider.');
    }
    return e;
  }

  Future<User> addXp(String email, int xp) async {
    if (xp <= 0) {
      throw ArgumentError('XP da aggiungere deve essere > 0.');
    }
    final key = _resolveEmail(email: email);

    final updated = await _repo.update(key, (u) {
      final beforeLevel = u.currentLevel.name;
      u.addXp(xp);
      final afterLevel = u.currentLevel.name;

      if (afterLevel != beforeLevel) {
      }
      return u;
    });
    _cache[key] = updated;
    _eventsCtrl.add(XpAdded(email: key, added: xp, totalXp: updated.xpReached));
    return updated;
  }

  Future<User> addXpWithLevelEvent(String email, int xp) async {
    if (xp <= 0) throw ArgumentError('XP da aggiungere deve essere > 0.');
    final key = _resolveEmail(email: email);
    final before = await getOrCreate(email: key);
    final beforeLevelName = before.currentLevel.name;

    final updated = await _repo.update(key, (u) {
      u.addXp(xp);
      return u;
    });

    _cache[key] = updated;
    _eventsCtrl.add(XpAdded(email: key, added: xp, totalXp: updated.xpReached));
    if (updated.currentLevel.name != beforeLevelName) {
      _eventsCtrl.add(LevelUp(
        email: key,
        fromLevelName: beforeLevelName,
        toLevelName: updated.currentLevel.name,
      ));
    }
    return updated;
  }

  Future<User> addFlamingo(String email, int flamingo) async {
    if (flamingo <= 0) {
      throw ArgumentError('Flamingo da aggiungere deve essere > 0.');
    }
    final key = _resolveEmail(email: email);

    final updated = await _repo.update(key, (u) {
      u.addFlamingo(flamingo);
      return u;
    });

    _cache[key] = updated;
    _eventsCtrl.add(FlamingoAdded(
      email: key,
      added: flamingo,
      totalFlamingo: updated.amount.amount,
    ));
    return updated;
  }

  Future<User> removeFlamingo(String email, int flamingo) async {
    if (flamingo <= 0) {
      throw ArgumentError('Flamingo da rimuovere deve essere > 0.');
    }
    final key = _resolveEmail(email: email);

    final updated = await _repo.update(key, (u) {
      u.removeFlamingo(flamingo);
      return u;
    });

    _cache[key] = updated;
    _eventsCtrl.add(FlamingoRemoved(
      email: key,
      removed: flamingo,
      totalFlamingo: updated.amount.amount,
    ));
    return updated;
  }

  Future<User> recomputeLevels(String email) async {
    final key = _resolveEmail(email: email);

    final updated = await _repo.update(key, (u) {
      final oldXp = u.xpReached;
      u.addXp(1);
      u.xpReached = oldXp;
      return u;
    });

    _cache[key] = updated;
    return updated;
  }

  Future<User?> getUserData(String email) => fetch(email);

  Future<void> dispose() async {
    await _eventsCtrl.close();
  }
}
