import 'package:flutter/material.dart';
import 'package:discover/features/gamification/domain/use_case/user_service.dart';
import 'package:discover/features/gamification/domain/entities/user.dart';

typedef EmailProvider = String? Function();

String _resolveEmail({String? email, EmailProvider? emailProvider}) {
  final resolved = (email ?? emailProvider?.call() ?? '').trim();
  if (resolved.isEmpty) {
    throw ArgumentError('Email non può essere vuota.');
  }
  return resolved;
}

/// Assegna XP all'utente (salva e aggiorna lo stato in memoria via UserService).
/// Se passi [context], mostra una SnackBar di conferma/errore.
Future<User> giveXp({
  required UserService service,
  String? email,
  EmailProvider? emailProvider,
  required int xp,
  BuildContext? context,
}) async {
  try {
    if (xp <= 0) throw ArgumentError('XP da aggiungere deve essere > 0.');
    final key = _resolveEmail(email: email, emailProvider: emailProvider);

    final updated = await service.addXpWithLevelEvent(key, xp);

    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('+$xp XP assegnati')),
      );
    }
    return updated;
  } catch (e) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore assegnazione XP: $e')),
      );
    }
    rethrow;
  }
}

/// Aggiunge o rimuove fenicotteri:
/// - qty > 0 => add
/// - qty < 0 => remove (rispetta gli assert della entity Flamingo)
/// Se passi [context], mostra una SnackBar di conferma/errore.
Future<User> giveFlamingo({
  required UserService service,
  String? email,
  EmailProvider? emailProvider,
  required int qty,
  BuildContext? context,
}) async {
  try {
    final key = _resolveEmail(email: email, emailProvider: emailProvider);
    if (qty == 0) {
      throw ArgumentError('Quantità fenicotteri non può essere 0.');
    }

    late final User updated;
    if (qty > 0) {
      updated = await service.addFlamingo(key, qty);
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+$qty fenicotteri')),
        );
      }
    } else {
      // qty < 0 -> remove
      updated = await service.removeFlamingo(key, -qty);
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$qty fenicotteri')), // es. -1
        );
      }
    }
    return updated;
  } catch (e) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore fenicotteri: $e')),
      );
    }
    rethrow;
  }
}