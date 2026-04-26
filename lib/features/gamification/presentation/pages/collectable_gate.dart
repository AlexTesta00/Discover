import 'dart:async';
import 'dart:math';

import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/gamification/domain/use_cases/collectible_service.dart';
import 'package:flutter_3d_carousel/flutter_3d_carousel.dart';
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
  StreamSubscription? _busSub;

  @override
  void initState() {
    super.initState();
    _future = _load();
    _busSub = ChallengeEventBus.I.stream.listen((e) {
      if (e is CollectibleAwardedEvent && mounted) {
        setState(() { _future = _load(); });
      }
    });
  }

  @override
  void dispose() {
    _busSub?.cancel();
    super.dispose();
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

          final unlockedCount = items.where((e) => e.unlocked).length;
          return SizedBox.expand(
            child: _WheelCarousel(
              items: items.map((item) => _CollectibleTile(key: ValueKey(item.id), item: item)).toList(),
              unlockedCount: unlockedCount,
              totalCount: items.length,
            ),
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
  final String? backAsset;
  final bool unlocked;

  _CollectibleVm({
    required this.id,
    required this.characterId,
    required this.name,
    required this.asset,
    required this.unlocked,
    this.backAsset,
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
      backAsset: c.backAsset,
      unlocked: unlocked,
    );
  }
}

class _CollectibleTile extends StatefulWidget {
  const _CollectibleTile({super.key, required this.item});
  final _CollectibleVm item;

  @override
  State<_CollectibleTile> createState() => _CollectibleTileState();
}

class _CollectibleTileState extends State<_CollectibleTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showBack = false;

  static const _grayMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    )..addListener(() {
        final back = _anim.value > pi / 2;
        if (back != _showBack) setState(() => _showBack = back);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    if (!widget.item.unlocked || _ctrl.isAnimating) return;
    if (_showBack) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    final img = Image.asset(
      widget.item.asset,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );

    final front = widget.item.unlocked
        ? img
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix(_grayMatrix),
            child: Opacity(opacity: 0.6, child: img),
          );

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, _) {
          final angle = _anim.value;
          final displayAngle = _showBack ? angle - pi : angle;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(displayAngle),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: _showBack
                  ? _CardBack(name: widget.item.name, backAsset: widget.item.backAsset)
                  : Container(
                      color: Colors.white,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Padding(padding: const EdgeInsets.all(10), child: front),
                          if (!widget.item.unlocked)
                            const Positioned(
                              top: 10,
                              right: 10,
                              child: Icon(Icons.lock, color: Colors.black38, size: 28),
                            ),
                        ],
                      ),
                    ),
            ),
          );
        },
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

  late final AnimationController _returnCtrl;
  late Animation<Offset> _returnAnim;

  static const _grayMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  @override
  void initState() {
    super.initState();
    _returnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

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

// ── 3D Wheel Carousel ────────────────────────────────────────────────────────

class _WheelCarousel extends StatefulWidget {
  const _WheelCarousel({
    required this.items,
    required this.unlockedCount,
    required this.totalCount,
  });

  final List<Widget> items;
  final int unlockedCount;
  final int totalCount;

  @override
  State<_WheelCarousel> createState() => _WheelCarouselState();
}

class _WheelCarouselState extends State<_WheelCarousel> {
  int _current = 0;
  int _pending = 0;

  static const _snapMs = 280;

  void _onValueChanged(double raw) {
    // Il valore cresce continuamente (anche oltre totalCount per via
    // dell'auto-rotazione), quindi usiamo il modulo per tornare all'indice.
    final n = widget.totalCount;
    // onValueChanged restituisce radianti (0–2π per giro completo).
    // Convertiamo in indice: raw / 2π * n, poi modulo per wrap-around.
    final idx = (((raw / (2 * pi)) * n).round() % n + n) % n;
    _pending = idx;
    Future.delayed(const Duration(milliseconds: _snapMs + 40), () {
      if (mounted && _pending != _current) {
        setState(() => _current = _pending);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final primary = Theme.of(context).colorScheme.primary;
    final children = widget.items.map((w) => CarouselChild(child: w)).toList();
    final total = widget.totalCount;

    // Mostra max 12 dots; se ci sono più elementi usa solo il testo
    final showDots = total <= 12;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          // ── Carosello ──────────────────────────────────────────
          Expanded(
            child: CarouselWidget3D(
              children: children,
              radius: size.height * 0.21,
              childScale: 0.78,
              perspectiveStrength: 0.0006,
              dragSensitivity: 1.2,
              snapTimeInMillis: _snapMs,
              timeForFullRevolution: 6000,
              isDragInteractive: true,
              shouldRotate: false,
              clockwise: true,
              spinAxis: Axis.horizontal,
              onValueChanged: _onValueChanged,
            ),
          ),

          const SizedBox(height: 16),

          // ── Dots ───────────────────────────────────────────────
          if (showDots) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(total, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: active ? primary : Colors.black12,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],

          // ── Contatore sbloccati ────────────────────────────────
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Colors.black45),
              children: [
                TextSpan(
                  text: '${widget.unlockedCount}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                TextSpan(text: ' / $total sbloccate'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flip Dialog (solo carte sbloccate) ───────────────────────────────────────

class _CollectibleFlipDialog extends StatefulWidget {
  const _CollectibleFlipDialog({required this.item});
  final _CollectibleVm item;

  @override
  State<_CollectibleFlipDialog> createState() => _CollectibleFlipDialogState();
}

class _CollectibleFlipDialogState extends State<_CollectibleFlipDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    )..addListener(() {
        final newShowBack = _anim.value > pi / 2;
        if (newShowBack != _showBack) setState(() => _showBack = newShowBack);
      });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_ctrl.isAnimating) return;
    if (_showBack) {
      _ctrl.reverse();
    } else {
      _ctrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width * 0.88;
    final h = size.height * 0.70;

    return SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const SizedBox.expand(),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: _toggle,
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, _) {
                    final angle = _anim.value;
                    final displayAngle = _showBack ? angle - pi : angle;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0016)
                        ..rotateY(displayAngle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: w,
                          height: h,
                          child: _showBack
                              ? _CardBack(name: widget.item.name, backAsset: widget.item.backAsset)
                              : _CardFront(asset: widget.item.asset),
                        ),
                      ),
                    );
                  },
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

class _CardFront extends StatelessWidget {
  const _CardFront({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18),
      child: Image.asset(asset, fit: BoxFit.contain),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.name, this.backAsset});
  final String name;
  final String? backAsset;

  @override
  Widget build(BuildContext context) {
    if (backAsset != null) {
      return Image.asset(backAsset!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, primary.withValues(alpha: 0.7)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 64),
          const SizedBox(height: 20),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Collezionabile sbloccato',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
