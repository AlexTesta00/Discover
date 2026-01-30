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

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return _CollectibleTile(item: item);
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

class _CollectibleTile extends StatelessWidget {
  const _CollectibleTile({required this.item});
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
    final borderRadius = BorderRadius.circular(16);

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

    return InkWell(
      borderRadius: borderRadius,
      onTap: () => showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'close',
        barrierColor: Colors.black.withValues(alpha: 0.6),
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) =>
            _CollectibleInteractive3DDialog(item: item),
      ),
      child: Hero(
        tag: 'collectible-${item.id}',
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            color: Colors.white,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(padding: const EdgeInsets.all(10), child: image),
                if (!item.unlocked)
                  const Positioned(
                    top: 10,
                    right: 10,
                    child: Icon(Icons.lock, color: Colors.black38, size: 28),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectibleInteractive3DDialog extends StatefulWidget {
  const _CollectibleInteractive3DDialog({required this.item});
  final _CollectibleVm item;

  @override
  State<_CollectibleInteractive3DDialog> createState() =>
      _CollectibleInteractive3DDialogState();
}

class _CollectibleInteractive3DDialogState
    extends State<_CollectibleInteractive3DDialog>
    with SingleTickerProviderStateMixin {
  Offset _tilt = Offset.zero;

  late final AnimationController _returnCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  late Animation<Offset> _returnAnim;

  static const _grayMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  @override
  void dispose() {
    _returnCtrl.dispose();
    super.dispose();
  }

  void _animateBack() {
    _returnCtrl.stop();
    _returnCtrl.reset();

    _returnAnim = Tween<Offset>(begin: _tilt, end: Offset.zero).animate(
      CurvedAnimation(parent: _returnCtrl, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() => _tilt = _returnAnim.value);
      });

    _returnCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(widget.item.asset, fit: BoxFit.contain);

    final image = widget.item.unlocked
        ? img
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix(_grayMatrix),
            child: Opacity(opacity: 0.6, child: img),
          );

    const maxTilt = 0.35;
    const perspective = 0.0016;
    final tiltX = (-_tilt.dy) * maxTilt;
    final tiltY = (_tilt.dx) * maxTilt;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, perspective)
      ..rotateX(tiltX)
      ..rotateY(tiltY);

    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            // sfondo tappabile per chiudere
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const SizedBox.expand(),
              ),
            ),

            Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (_) {
                  _returnCtrl.stop();
                },
                onPanUpdate: (details) {
                  final size = MediaQuery.of(context).size;
                  final nx = (details.delta.dx / (size.width * 0.55));
                  final ny = (details.delta.dy / (size.height * 0.55));

                  setState(() {
                    _tilt = Offset(
                      (_tilt.dx + nx).clamp(-1.0, 1.0),
                      (_tilt.dy + ny).clamp(-1.0, 1.0),
                    );
                  });
                },
                onPanEnd: (_) => _animateBack(),
                onPanCancel: _animateBack,
                child: Transform(
                  alignment: Alignment.center,
                  transform: transform,
                  child: _Card3DFrame(
                    unlocked: widget.item.unlocked,
                    tilt: _tilt,
                    child: image,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card3DFrame extends StatelessWidget {
  const _Card3DFrame({
    required this.child,
    required this.unlocked,
    required this.tilt,
  });

  final Widget child;
  final bool unlocked;
  final Offset tilt;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.88;
    final h = MediaQuery.of(context).size.height * 0.70;
    final shineX = (tilt.dx * 0.6).clamp(-0.8, 0.8);
    final shineY = (tilt.dy * 0.6).clamp(-0.8, 0.8);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: w,
        height: h,
        color: Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: child,
            ),
            IgnorePointer(
              child: Opacity(
                opacity: 0.22,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(shineX, shineY),
                      radius: 1.2,
                      colors: const [
                        Colors.white,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (!unlocked)
              const Positioned(
                top: 16,
                right: 16,
                child: Icon(Icons.lock, color: Colors.black38, size: 44),
              ),
          ],
        ),
      ),
    );
  }
}
