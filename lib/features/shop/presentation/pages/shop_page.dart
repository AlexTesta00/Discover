import 'dart:async';
import 'package:discover/core/app_service.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/gamification/domain/use_case/user_service.dart';
import 'package:flutter/material.dart';
import 'package:discover/features/shop/domain/entities/shop_item.dart';
import 'package:discover/features/shop/domain/entities/shop_item_type.dart';
import 'package:discover/features/shop/domain/repository/shop_repository.dart';
import 'package:discover/features/shop/presentation/widgets/shop_data.dart';
import 'package:discover/features/shop/presentation/widgets/shop_error.dart';
import 'package:discover/features/shop/presentation/widgets/shop_loading.dart';
import 'package:discover/features/shop/presentation/widgets/shop_section.dart';
import 'package:discover/features/shop/domain/repository/shop_prefs.dart';
import 'package:discover/features/gamification/utils.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, this.onTapItem});

  final void Function(ShopItem item)? onTapItem;

  @override
  ShopPageState createState() => ShopPageState();
}

class ShopPageState extends State<ShopPage> {
  // ---- Dati shop
  final _repo = const ShopRepository();
  Future<ShopData>? _shopFuture;

  // ---- Utente / fenicotteri (condiviso)
  final _userService = AppServices.userService;
  StreamSubscription<UserEvent>? _userSub;

  String? _email;
  bool _userReady = false;
  String? _userError;
  int? _flamingos;

  // ---- Owned in memoria
  Set<String> _ownedBg = {};
  Set<String> _ownedAv = {};

  @override
  void initState() {
    super.initState();
    _reloadShop();
    _initUser();
    _loadOwned();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  void refreshFromOutside() {
    _refreshBalance();
    _loadOwned();
  }

  // ---------------- Bootstrap ----------------
  void _reloadShop() {
    final f = _loadShop();
    setState(() {
      _shopFuture = f;
    });
  }

  Future<ShopData> _loadShop() async {
    final result = await Future.wait([
      _repo.loadBackgrounds(),
      _repo.loadAvatars(),
    ]);
    return ShopData(backgrounds: result[0], avatars: result[1]);
  }

  Future<void> _initUser() async {
    try {
      final email = getUserEmail();
      if ((email ?? '').isEmpty) {
        setState(() {
          _userError = 'Email non presente';
          _userReady = true;
        });
        return;
      }
      _email = email;

      await _userService.getOrCreate(email: _email);
      await _refreshBalance();

      _listenUserEvents();

      setState(() {
        _userReady = true;
      });
    } catch (e) {
      setState(() {
        _userError = 'Errore utente: $e';
        _userReady = true;
      });
    }
  }

  void _listenUserEvents() {
    _userSub?.cancel();
    _userSub = _userService.events.listen((evt) async {
      if (evt.email != _email) return;
      await _refreshBalance();
    });
  }

  Future<void> _loadOwned() async {
    final bg = await ShopPrefs.getOwned(ShopItemType.background);
    final av = await ShopPrefs.getOwned(ShopItemType.avatar);
    if (!mounted) return;
    setState(() {
      _ownedBg = bg;
      _ownedAv = av;
    });
  }

  Future<int> _refreshBalance() async {
    if (_email == null || _email!.isEmpty) {
      _email = getUserEmail();
      if (_email == null || _email!.isEmpty) return _flamingos ?? 0;
    }
    final count = await getCurrentFlamingo(
      service: _userService,
      email: _email,
    );
    if (mounted) {
      setState(() {
        _flamingos = count;
      });
    }
    return count;
  }

  bool _isOwned(ShopItem item) {
    return item.type == ShopItemType.background
        ? _ownedBg.contains(item.asset)
        : _ownedAv.contains(item.asset);
  }

  Future<bool> _ensureCanBuy(int cost) async {
    final cur = _flamingos ?? await _refreshBalance();
    return cur >= cost;
  }

  Future<void> _onTapItem(ShopItem item) async {
    widget.onTapItem?.call(item);

    if (!_isOwned(item)) {
      final balance = _flamingos ?? await _refreshBalance();
      final doBuy = await _showPurchaseDialog(item: item, balance: balance);
      if (doBuy != true) return;

      if (!await _ensureCanBuy(item.cost)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fenicotteri insufficienti.')),
          );
        }
        return;
      }

      try {
        await giveFlamingo(
          service: _userService,
          email: _email,
          qty: -item.cost,
          context: context,
        );
        await _refreshBalance();
        await ShopPrefs.addOwned(item);

        setState(() {
          if (item.type == ShopItemType.background) {
            _ownedBg.add(item.asset);
          } else {
            _ownedAv.add(item.asset);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Acquisto riuscito: ${item.title}')),
          );
        }
      } catch (_) {
        // giveFlamingo mostra già snackbar d'errore
      }
      return;
    }

    // Già acquistato → chiedi se impostarlo
    final setIt = await _showSetDialog(item: item);
    if (setIt == true) {
      await ShopPrefs.setSelected(item);
      if (!mounted) return;
      final what = item.type == ShopItemType.background ? 'Sfondo impostato' : 'Avatar impostato';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(what)));
      Navigator.of(context).maybePop(true); // notifica la pagina chiamante
    }
  }

  Future<bool?> _showPurchaseDialog({
    required ShopItem item,
    required int balance,
  }) {
    final canBuy = balance >= item.cost;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Compra "${item.title}"?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    item.asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.whatshot, size: 18, color: Colors.pink),
                const SizedBox(width: 8),
                Text('Costo: ${item.cost}'),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.savings_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Disponibili: $balance'),
              ]),
              if (!canBuy) ...[
                const SizedBox(height: 8),
                Text(
                  'Fenicotteri insufficienti',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: canBuy ? () => Navigator.of(context).pop(true) : null,
              child: const Text('Compra'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showSetDialog({required ShopItem item}) {
    final isBg = item.type == ShopItemType.background;
    final title = isBg ? 'Vuoi impostare questo sfondo?' : 'Vuoi impostare questo avatar?';

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title),
          content: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                item.asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sì'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUserError = _userError != null;

    return Scaffold(
      body: FutureBuilder<ShopData>(
        future: _shopFuture,
        builder: (context, snapshot) {
          final shopLoading = snapshot.connectionState == ConnectionState.waiting || _shopFuture == null;
          final userLoading = !_userReady && _userError == null;

          if (shopLoading || userLoading) {
            return const ShopLoading();
          }
          if (snapshot.hasError) {
            return ShopError(
              message: 'Errore shop: ${snapshot.error}',
              onRetry: _reloadShop,
            );
          }
          if (hasUserError) {
            return ShopError(
              message: _userError!,
              onRetry: _initUser,
            );
          }

          final data = snapshot.requireData;

          return CustomScrollView(
            slivers: [
              ShopSection(
                title: 'Sfondi',
                items: data.backgrounds,
                isOwned: _isOwned,
                onTap: _onTapItem,
              ),
              ShopSection(
                title: 'Avatar',
                items: data.avatars,
                isOwned: _isOwned,
                onTap: _onTapItem,
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          );
        },
      ),
    );
  }
}
