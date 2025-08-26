import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/challenge/domain/repository/challenge_store.dart';
import 'package:discover/features/challenge/presentation/widgets/section_header.dart';
import 'package:flutter/material.dart';
import '../widgets/challenge_card.dart';

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  final _repo = ChallengeRepository();
  final _store = CompletedStore();
  late Future<List<Challenge>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamColor,
      body: FutureBuilder<List<Challenge>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Errore nel caricamento: ${snapshot.error}'),
            );
          }
          final items = snapshot.data ?? const <Challenge>[];
          return ListView(
            children: [
              const SectionHeader(''),
              ...items.map(
                (c) => ChallengeCard(challenge: c, store: _store),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
