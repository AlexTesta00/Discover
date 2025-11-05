import 'package:discover/features/gamification/domain/use_cases/collectible_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:discover/features/gamification/domain/entities/collectible.dart';

class CollectibleGate extends StatefulWidget {
  const CollectibleGate({super.key});

  @override
  State<CollectibleGate> createState() => _CollectibleGateState();
}

class _CollectibleGateState extends State<CollectibleGate> {
  late final CollectiblesService _service = CollectiblesService(
    Supabase.instance.client,
  );
  late Future<List<_CollectibleVm>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_CollectibleVm>> _load() async {
    final mine = await _service.listMyCollectibles();
    final missing = await _service.listMissingCollectibles();

    final unlocked = mine
        .map((c) => _CollectibleVm.fromCollectible(c, unlocked: true))
        .toList();
    final locked = missing
        .map((c) => _CollectibleVm.fromCollectible(c, unlocked: false))
        .toList();

    return [...unlocked, ...locked];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<_CollectibleVm>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Errore: ${snap.error}'));
          }

          final items = snap.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Nessun collezionabile.'));
          }

          return PageView.builder(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return _CollectibleFullPage(item: item);
            },
          );
        },
      ),
    );
  }
}

/// ViewModel per unire sbloccati e mancanti
class _CollectibleVm {
  final String id;
  final String characterId;
  final String name;
  final String asset;
  final bool unlocked;

  _CollectibleVm({
    required this.id,
    required this.characterId,
    required this.name,
    required this.asset,
    required this.unlocked,
  });

  factory _CollectibleVm.fromCollectible(
    Collectible c, {
    required bool unlocked,
  }) {
    return _CollectibleVm(
      id: c.collectibleId,
      characterId: c.characterId,
      name: c.collectibleName.isNotEmpty ? c.collectibleName : c.characterName,
      asset: c.asset,
      unlocked: unlocked,
    );
  }
}

/// Pagina a schermo intero del singolo collezionabile
class _CollectibleFullPage extends StatelessWidget {
  const _CollectibleFullPage({required this.item});
  final _CollectibleVm item;

  static const _grayMatrix = <double>[
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0.2126,
    0.7152,
    0.0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      item.asset,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );

    final image = item.unlocked
        ? img
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix(_grayMatrix),
            child: Opacity(opacity: 0.6, child: img),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.white),
        Center(child: image),
        if (!item.unlocked)
          const Positioned(
            top: 60,
            right: 24,
            child: Icon(Icons.lock, color: Colors.black38, size: 48),
          ),
      ],
    );
  }
}
