import 'dart:async';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/challenge/presentation/widgets/challenge_card.dart';
import 'package:discover/features/challenge/presentation/widgets/challenge_filter_bar.dart';
import 'package:discover/features/challenge/presentation/widgets/modal_success_challenge.dart';
import 'package:discover/features/events/domain/use_cases/event_service.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum ChallengeFilter { all, todo, done }

class ChallengeGatePage extends StatefulWidget {
  const ChallengeGatePage({super.key});

  @override
  State<ChallengeGatePage> createState() => _ChallengeGatePageState();
}

class _ChallengeGatePageState extends State<ChallengeGatePage> {
  late final ChallengeRepository repo;

  ChallengeFilter filter = ChallengeFilter.all;
  bool loading = true;
  Object? error;

  List<Challenge> all = const [];
  Set<String> doneIds = const {};

  StreamSubscription? _busSub;

  @override
  void initState() {
    super.initState();
    repo = ChallengeRepository(Supabase.instance.client);

    _busSub = ChallengeEventBus.I.stream.listen((e) async {
      if (e is ChallengeCompletedEvent) {
        try {
          // 1) assegna XP + Fenicotteri all’utente
          await addXpAndBalance(
            xp: e.challenge.xp,
            balance: e.challenge.fenicotteri,
          );

          // 2) mostra il modale di successo
          if (mounted) {
            await showSuccessChallengeModal(context, challenge: e.challenge);
          }

          // 3) Aggiorna gli amici
          await addEvent("Ha completato la challenge '${e.challenge.title}'!");

          // 4) ricarica la lista
          await _load();
        } catch (err) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Errore aggiornamento profilo: $err')),
            );
          }
        }
      } else if (e is ChallengeCompletionFailedEvent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invio fallito: ${e.error}')),
          );
        }
      }
    });

    _load();
  }

  @override
  void dispose() {
    _busSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final results = await Future.wait([
        repo.fetchAllWithCharacter(),
        repo.fetchCompletedIds(),
      ]);
      setState(() {
        all = results[0] as List<Challenge>;
        doneIds = results[1] as Set<String>;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e;
        loading = false;
      });
    }
  }

  List<Challenge> _filtered() {
    final now = DateTime.now();

    bool isOpen(Challenge c) {
      final started = c.startAt == null || !c.startAt!.isAfter(now);
      final notEnded = c.endAt == null || !c.endAt!.isBefore(now);
      return c.isActive && started && notEnded;
    }

    switch (filter) {
      case ChallengeFilter.all:
        return all;
      case ChallengeFilter.todo:
        return all.where((c) => isOpen(c) && !doneIds.contains(c.id)).toList();
      case ChallengeFilter.done:
        return all.where((c) => doneIds.contains(c.id)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              ChallengeFilterBar(
                current: filter,
                onChanged: (f) => setState(() => filter = f),
              ),
              const SizedBox(height: 12),
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'Ops! $error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                )
              else if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Column(
                    children: [
                      const Icon(Icons.inbox_outlined, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        switch (filter) {
                          ChallengeFilter.all => 'Nessuna challenge disponibile',
                          ChallengeFilter.todo => 'Hai completato tutto 🎉',
                          ChallengeFilter.done => 'Nessuna challenge completata',
                        },
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                ...items.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ChallengeCard(
                        challenge: c,
                        completed: doneIds.contains(c.id),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
