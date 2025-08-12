import 'package:discover/features/gamification/domain/repository/level_catalog.dart';
import 'package:discover/features/gamification/domain/repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:discover/features/gamification/domain/entities/user.dart';
import 'package:discover/features/gamification/domain/entities/flamingo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UserRepository (email come chiave)', () {
    test('fetch(email) -> null quando non esiste', () async {
      final repo = UserRepository();
      final u = await repo.fetch('none@mail.com');
      expect(u, isNull);
    });

    test('getOrCreate crea e salva con chiave = email', () async {
      final repo = UserRepository();
      final u = await repo.getOrCreate(email: 'mock@mail.com');

      expect(u.email, 'mock@mail.com');
      expect(u.xpReached, 0);
      expect(u.amount.amount, 0);
      expect(u.currentLevel.name, defaultLevels.first.name);

      // nuova istanza repo: fetch by email deve recuperare
      final repo2 = UserRepository();
      final fetched = await repo2.fetch('mock@mail.com');
      expect(fetched, isNotNull);
      expect(fetched!.email, 'mock@mail.com');
    });

    test('getOrCreate con provider viene salvato su chiave = email risolta', () async {
      final repo = UserRepository();
      String? getEmail() => 'provider@mail.com';
      final u = await repo.getOrCreate(emailProvider: getEmail);

      expect(u.email, 'provider@mail.com');
      final fetched = await repo.fetch('provider@mail.com');
      expect(fetched, isNotNull);
      expect(fetched!.email, 'provider@mail.com');
    });

    test('save() sovrascrive lo stato per quella email', () async {
      final repo = UserRepository();
      var u = await repo.getOrCreate(email: 'x@y.z');
      u.addXp(260);
      u.addFlamingo(5);
      await repo.save(u);

      final fetched = await repo.fetch('x@y.z');
      expect(fetched, isNotNull);
      expect(fetched!.xpReached, 260);
      expect(fetched.currentLevel.name, 'Level 3');
      expect(fetched.amount.amount, 5);
    });

    test('update(email) applica modifiche, salva e ritorna aggiornato', () async {
      final repo = UserRepository();
      await repo.getOrCreate(email: 'u@ex.com');

      final updated = await repo.update('u@ex.com', (u) {
        u.addXp(100);
        u.addFlamingo(3);
        return u;
      });

      expect(updated.xpReached, 100);
      expect(updated.currentLevel.name, 'Level 2');
      expect(updated.nextLevel?.name, 'Level 3');
      expect(updated.amount.amount, 3);

      final fetched = await repo.fetch('u@ex.com');
      expect(fetched!.xpReached, 100);
      expect(fetched.amount.amount, 3);
    });

    test('clear(email) rimuove SOLO quell’utente', () async {
      final repo = UserRepository();

      await repo.getOrCreate(email: 'a@b.c');
      await repo.getOrCreate(email: 'b@c.d');

      // rimuovo il primo
      await repo.clear('a@b.c');

      expect(await repo.fetch('a@b.c'), isNull);
      expect(await repo.fetch('b@c.d'), isNotNull); // l’altro resta
    });

    test('fetch gestisce JSON corrotto sulla chiave dell’email', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bad@mail.com', 'NOT_JSON');

      final repo = UserRepository();
      final u = await repo.fetch('bad@mail.com');
      expect(u, isNull);
    });

    test('round-trip per una email preserva i dati', () async {
      final repo = UserRepository();
      final email = 'round@trip.io';
      final user = User(
        email: email,
        xpReached: 500,
        amount: Flamingo(amount: 7),
      );
      await repo.save(user);

      final fetched = await repo.fetch(email);
      expect(fetched, isNotNull);
      expect(fetched!.email, email);
      expect(fetched.xpReached, 500);
      expect(fetched.currentLevel.name, 'Level 4');
      expect(fetched.nextLevel?.name, 'Level 5');
      expect(fetched.amount.amount, 7);
      expect(fetched.levels.length, defaultLevels.length);
    });

    test('getOrCreate lancia se email è vuota (o provider vuoto)', () async {
      final repo = UserRepository();
      expect(
        () => repo.getOrCreate(email: ''),
        throwsA(isA<ArgumentError>()),
      );

      String? emptyProvider() => '';
      expect(
        () => repo.getOrCreate(emailProvider: emptyProvider),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('può gestire più utenti indipendenti (chiavi diverse)', () async {
      final repo = UserRepository();

      final u1 = await repo.getOrCreate(email: 'alice@mail.com');
      final u2 = await repo.getOrCreate(email: 'bob@mail.com');

      await repo.update('alice@mail.com', (u) {
        u.addXp(100);
        u.addFlamingo(2);
        return u;
      });

      await repo.update('bob@mail.com', (u) {
        u.addXp(260);
        u.addFlamingo(5);
        return u;
      });

      final a = await repo.fetch('alice@mail.com');
      final b = await repo.fetch('bob@mail.com');

      expect(a!.xpReached, 100);
      expect(a.currentLevel.name, 'Level 2');
      expect(a.amount.amount, 2);

      expect(b!.xpReached, 260);
      expect(b.currentLevel.name, 'Level 3');
      expect(b.amount.amount, 5);
    });
  });
}
