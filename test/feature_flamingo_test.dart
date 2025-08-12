import 'package:discover/features/gamification/domain/entities/flamingo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Flamingo', () {
    test('costruttore di default imposta amount = 0', () {
      final f = Flamingo();
      expect(f.amount, 0);
    });

    test('costruttore accetta un amount iniziale', () {
      final f = Flamingo(amount: 10);
      expect(f.amount, 10);
    });

    test('getter amount riflette lo stato corrente', () {
      final f = Flamingo(amount: 2);
      f.addFlamingo(3); // diventa 5
      expect(f.amount, 5);
    });

    test('addFlamingo incrementa amount quando > 0', () {
      final f = Flamingo(amount: 1);
      f.addFlamingo(4);
      expect(f.amount, 5);
    });

    test('addFlamingo lancia se flamingo <= 0', () {
      final f = Flamingo();
      expect(() => f.addFlamingo(0), throwsA(isA<AssertionError>()));
      expect(() => f.addFlamingo(-1), throwsA(isA<AssertionError>()));
    });

    test('removeFlamingo decrementa amount se il risultato resta > 0', () {
      final f = Flamingo(amount: 5);
      f.removeFlamingo(3);
      expect(f.amount, 2);
    });

    test('removeFlamingo lancia se flamingo <= 0', () {
      final f = Flamingo(amount: 5);
      expect(() => f.removeFlamingo(0), throwsA(isA<AssertionError>()));
      expect(() => f.removeFlamingo(-2), throwsA(isA<AssertionError>()));
    });

    test('removeFlamingo lancia se il risultato non è > 0 (== 0 o negativo)', () {
      final f = Flamingo(amount: 5);
      expect(() => f.removeFlamingo(5), throwsA(isA<AssertionError>())); // 0 -> non consentito
      expect(() => f.removeFlamingo(6), throwsA(isA<AssertionError>())); // negativo
    });

    test('sequenza di operazioni mantiene l’invariante amount > 0', () {
      final f = Flamingo(amount: 3);
      f.addFlamingo(2);      // 5
      f.removeFlamingo(1);   // 4
      f.addFlamingo(10);     // 14
      f.removeFlamingo(13);  // 1 (ancora > 0)
      expect(f.amount, 1);
    });
  });
}
