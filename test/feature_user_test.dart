import 'package:discover/features/gamification/domain/entities/user.dart';
import 'package:discover/features/gamification/domain/entities/flamingo.dart';
import 'package:discover/features/gamification/domain/entities/level.dart';
import 'package:discover/features/gamification/domain/repository/level_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User - livelli default e inizializzazione', () {
    test('usa i defaultLevels quando non vengono passati', () {
      final u = User(email: 'x@y.z');
      expect(u.levels, defaultLevels);
      expect(u.currentLevel, defaultLevels.first);
      expect(u.nextLevel, defaultLevels[1]);
      expect(u.xpReached, 0);
      expect(u.amount.amount, 0);
    });

    test('inizializzazione con xpReached posiziona current e next coerenti', () {
      final u = User(email: 'x@y.z', xpReached: 120);
      // 120 >= 100 (Level 2), < 250 (Level 3)
      expect(u.currentLevel.name, 'Raccoglitore di indizi');
      expect(u.nextLevel?.name, 'Cercatore di piume');
    });

    test('email presa dal provider se non passata esplicitamente', () {
      String? provider() => 'provider@mail.com';
      final u = User(emailProvider: provider);
      expect(u.email, 'provider@mail.com');
    });

    test('email esplicita ha priorità sul provider', () {
      String? provider() => 'provider@mail.com';
      final u = User(email: 'explicit@mail.com', emailProvider: provider);
      expect(u.email, 'explicit@mail.com');
    });
  });

  group('User - progressione livelli con XP', () {
    test('addXp su soglia esatta: passa al livello successivo', () {
      final u = User(email: 'x@y.z'); // L1 (0)
      u.addXp(100); // soglia L2
      expect(u.currentLevel.name, 'Raccoglitore di indizi');
      expect(u.nextLevel?.name, 'Cercatore di piume');
      expect(u.xpReached, 100);
    });

    test('addXp con salto di più livelli in una volta sola', () {
      final u = User(email: 'x@y.z'); // L1
      u.addXp(260); // > 250 => L3
      expect(u.currentLevel.name, 'Cercatore di piume');
      expect(u.nextLevel?.name, 'Osservatore di Nidi');
      expect(u.xpReached, 260);
    });

    test('computeNextLevel restituisce il prossimo livello atteso', () {
      final u = User(email: 'x@y.z', xpReached: 500);
      final next = u.computeNextLevel();
      expect(u.currentLevel.name, 'Cacciatore di rarità');
      expect(next?.name, 'Catalogatore di specie');
    });

    test('raggiunto ultimo livello: nextLevel diventa null', () {
      final u = User(email: 'x@y.z');
      u.addXp(5000);
      expect(u.currentLevel.name, 'Leggenda della ricerca');
      expect(u.nextLevel, isNull);
    });

    test('addXp rifiuta 0 o negativi (assert)', () {
      final u = User(email: 'x@y.z');
      expect(() => u.addXp(0), throwsA(isA<AssertionError>()));
      expect(() => u.addXp(-10), throwsA(isA<AssertionError>()));
    });
  });

  group('User - Flamingo delega', () {
    test('addFlamingo aumenta il saldo', () {
      final u = User(email: 'x@y.z');
      u.addFlamingo(3);
      expect(u.amount.amount, 3);
    });

    test('removeFlamingo diminuisce il saldo', () {
      final u = User(email: 'x@y.z');
      u.addFlamingo(5);
      u.removeFlamingo(2);
      expect(u.amount.amount, 3);
    });

    test('removeFlamingo: assert se si tenta di arrivare a 0 o sotto', () {
      final u = User(email: 'x@y.z');
      u.addFlamingo(1);
      expect(() => u.removeFlamingo(1), throwsA(isA<AssertionError>())); // 1-1=0 non consentito
      expect(() => u.removeFlamingo(2), throwsA(isA<AssertionError>())); // 1-2<0
    });

    test('getter e setter amount funzionano', () {
      final f = Flamingo(amount: 7);
      expect(f.amount, 7);
      f.amount = 12;
      expect(f.amount, 12);
    });

    test('addFlamingo/removeFlamingo validano input (assert > 0)', () {
      final u = User(email: 'x@y.z');
      expect(() => u.addFlamingo(0), throwsA(isA<AssertionError>()));
      expect(() => u.addFlamingo(-1), throwsA(isA<AssertionError>()));
      u.addFlamingo(3);
      expect(() => u.removeFlamingo(0), throwsA(isA<AssertionError>()));
      expect(() => u.removeFlamingo(-2), throwsA(isA<AssertionError>()));
    });
  });

  group('User - livelli custom', () {
    test('rispetta una lista di livelli custom passata al costruttore', () {
      final custom = <Level>[
        Level(name: 'Bronze', xpToReachLevel: 0, imageUrl: 'bronze.png'),
        Level(name: 'Silver', xpToReachLevel: 10, imageUrl: 'silver.png'),
        Level(name: 'Gold', xpToReachLevel: 50, imageUrl: 'gold.png'),
      ];

      final u = User(
        email: 'x@y.z',
        levels: custom,
        xpReached: 12,
      );

      expect(u.levels, custom);
      expect(u.currentLevel.name, 'Silver');
      expect(u.nextLevel?.name, 'Gold');
    });

    test('inizializzazione con currentLevel/nextLevel espliciti viene mantenuta', () {
      final custom = <Level>[
        Level(name: 'L1', xpToReachLevel: 0, imageUrl: 'l1.png'),
        Level(name: 'L2', xpToReachLevel: 5, imageUrl: 'l2.png'),
      ];

      final u = User(
        email: 'x@y.z',
        levels: custom,
        currentLevel: custom.first,
        nextLevel: custom.last,
        xpReached: 0,
      );

      expect(u.currentLevel, custom.first);
      expect(u.nextLevel, custom.last);
    });
  });
}
