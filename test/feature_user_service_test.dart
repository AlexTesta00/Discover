import 'package:discover/features/gamification/domain/repository/level_catalog.dart';
import 'package:discover/features/gamification/domain/repository/user_repository.dart';
import 'package:discover/features/gamification/domain/use_case/user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discover/features/gamification/domain/entities/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserRepository repo;
  late UserService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = UserRepository();
    service = UserService(repo);
  });

  tearDown(() async {
    await service.dispose();
  });

  Future<void> _drainMicrotasks() async {
    await Future<void>.delayed(Duration.zero);
  }

  group('UserService – bootstrap & fetch', () {
    test('getOrCreate crea l’utente se non esiste e lo persiste', () async {
      final u = await service.getOrCreate(email: 'a@b.c');

      expect(u.email, 'a@b.c');
      expect(u.xpReached, 0);
      expect(u.amount.amount, 0);
      expect(u.currentLevel.name, defaultLevels.first.name);
      expect(u.nextLevel?.name, defaultLevels[1].name);

      final fromRepo = await repo.fetch('a@b.c');
      expect(fromRepo, isNotNull);
      expect(fromRepo!.email, 'a@b.c');
    });

    test('fetch ritorna da cache se già caricato, altrimenti da storage', () async {
      await service.getOrCreate(email: 'cache@test.com');

      final first = await service.fetch('cache@test.com');
      final second = await service.fetch('cache@test.com');

      expect(identical(first, second), isTrue);
    });

    test('getEmail usa il provider e valida non-vuoto', () {
      String? good() => 'x@y.z';
      expect(service.getEmail(emailProvider: good), 'x@y.z');

      String? bad() => '';
      expect(() => service.getEmail(emailProvider: bad), throwsArgumentError);
    });
  });

  group('UserService – XP & LevelUp', () {
  test('addXpWithLevelEvent emette XpAdded e LevelUp quando si supera una soglia', () async {
    const email = 'xp@test.com';
    await service.getOrCreate(email: email);

    final events = <UserEvent>[];
    final sub = service.events.listen(events.add);

    final updated = await service.addXpWithLevelEvent(email, 120);
    await _drainMicrotasks();

    expect(updated.xpReached, 120);
    expect(updated.currentLevel.name, 'Raccoglitore di indizi');
    expect(updated.nextLevel?.name, 'Cercatore di piume');

    final reloaded = await repo.fetch(email);
    expect(reloaded!.xpReached, 120);
    expect(reloaded.currentLevel.name, 'Raccoglitore di indizi');

    expect(events.length, 2);
    expect(events[0], isA<XpAdded>());
    expect((events[0] as XpAdded).added, 120);
    expect((events[0] as XpAdded).totalXp, 120);

    expect(events[1], isA<LevelUp>());
    final lvl = events[1] as LevelUp;
    expect(lvl.fromLevelName, 'Scout delle orme');
    expect(lvl.toLevelName, 'Raccoglitore di indizi');

    await sub.cancel();
  });

  test('addXpWithLevelEvent con salto di più livelli emette un LevelUp (L1->L3)', () async {
    const email = 'jump@test.com';
    await service.getOrCreate(email: email);

    final events = <UserEvent>[];
    final sub = service.events.listen(events.add);

    final updated = await service.addXpWithLevelEvent(email, 260);
    await _drainMicrotasks();

    expect(updated.currentLevel.name, 'Cercatore di piume');
    expect(updated.xpReached, 260);

    expect(events.whereType<XpAdded>().length, 1);
    expect(events.whereType<LevelUp>().length, 1);
    final up = events.whereType<LevelUp>().first;
    expect(up.fromLevelName, 'Scout delle orme');
    expect(up.toLevelName, 'Cercatore di piume');

    await sub.cancel();
  });

    test('addXpWithLevelEvent rifiuta xp <= 0', () async {
      const email = 'neg@test.com';
      await service.getOrCreate(email: email);
      expect(() => service.addXpWithLevelEvent(email, 0), throwsArgumentError);
      expect(() => service.addXpWithLevelEvent(email, -5), throwsArgumentError);
    });
  });

  group('UserService – Flamingo', () {
    test('addFlamingo emette FlamingoAdded e salva', () async {
      const email = 'flam+@test.com';
      await service.getOrCreate(email: email);

      final events = <UserEvent>[];
      final sub = service.events.listen(events.add);

      final updated = await service.addFlamingo(email, 3);
      expect(updated.amount.amount, 3);

      final reloaded = await repo.fetch(email);
      expect(reloaded!.amount.amount, 3);

      expect(events.length, 1);
      expect(events.first, isA<FlamingoAdded>());
      final e = events.first as FlamingoAdded;
      expect(e.added, 3);
      expect(e.totalFlamingo, 3);

      await sub.cancel();
    });

    test('removeFlamingo emette FlamingoRemoved e salva', () async {
      const email = 'flam-@test.com';
      await service.getOrCreate(email: email);
      await service.addFlamingo(email, 2);

      final events = <UserEvent>[];
      final sub = service.events.listen(events.add);

      final updated = await service.removeFlamingo(email, 1);
      expect(updated.amount.amount, 1);

      final reloaded = await repo.fetch(email);
      expect(reloaded!.amount.amount, 1);

      final removedEvt = events.whereType<FlamingoRemoved>().last;
      expect(removedEvt.removed, 1);
      expect(removedEvt.totalFlamingo, 1);

      await sub.cancel();
    });

    test('removeFlamingo fallisce se porterebbe il saldo a 0 o negativo', () async {
      const email = 'flam-assert@test.com';
      await service.getOrCreate(email: email);
      await service.addFlamingo(email, 1);

      expect(() => service.removeFlamingo(email, 1), throwsA(isA<AssertionError>()));
    });

    test('addFlamingo/removeFlamingo rifiutano input <= 0', () async {
      const email = 'flam-arg@test.com';
      await service.getOrCreate(email: email);
      expect(() => service.addFlamingo(email, 0), throwsArgumentError);
      expect(() => service.addFlamingo(email, -1), throwsArgumentError);
      expect(() => service.removeFlamingo(email, 0), throwsArgumentError);
      expect(() => service.removeFlamingo(email, -2), throwsArgumentError);
    });
  });

  group('UserService – multiuser & dati utente', () {
    test('utenti diversi sono isolati', () async {
      await service.getOrCreate(email: 'alice@mail.com');
      await service.getOrCreate(email: 'bob@mail.com');

      await service.addXpWithLevelEvent('alice@mail.com', 100);
      await service.addFlamingo('alice@mail.com', 2);

      await service.addXpWithLevelEvent('bob@mail.com', 260);
      await service.addFlamingo('bob@mail.com', 5);

      final a = await service.getUserData('alice@mail.com');
      final b = await service.getUserData('bob@mail.com');

      expect(a!.currentLevel.name, 'Raccoglitore di indizi');
      expect(a.amount.amount, 2);

      expect(b!.currentLevel.name, 'Cercatore di piume');
      expect(b.amount.amount, 5);
    });

    test('getUserData ritorna l’utente corrente', () async {
      await service.getOrCreate(email: 'data@test.com');
      final u = await service.getUserData('data@test.com');
      expect(u, isA<User>());
    });
  });

  group('UserService – recomputeLevels', () {
    test('recomputeLevels ricalcola current/next e salva', () async {
      const email = 'recompute@test.com';
      final u0 = await service.getOrCreate(email: email);
      expect(u0.currentLevel.name, 'Scout delle orme');

      final u1 = await service.addXpWithLevelEvent(email, 260);
      expect(u1.currentLevel.name, 'Cercatore di piume');

      final u2 = await service.recomputeLevels(email);
      expect(u2.currentLevel.name, 'Cercatore di piume');

      final reloaded = await repo.fetch(email);
      expect(reloaded!.currentLevel.name, 'Cercatore di piume');
    });
  });
}
