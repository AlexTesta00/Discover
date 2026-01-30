import 'dart:async';

import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/authentication/presentation/state_management/authentication_gate.dart';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/presentation/pages/challenge_gate.dart';
import 'package:discover/features/dashboard/presentation/widgets/balance_pill.dart';
import 'package:discover/features/gamification/presentation/pages/collectable_gate.dart';
import 'package:discover/features/maps/presentation/pages/map_gate.dart';
import 'package:discover/features/profile/presentation/state_management/profile_screen_state.dart';
import 'package:discover/features/shop/presentation/pages/shop_gate.dart';
import 'package:discover/features/user/presentation/widgets/balance_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final _controller = PersistentTabController(initialIndex: 0);
  bool _loggingOut = false;
  static const int _profileTabIndex = 2;
  StreamSubscription? _busSub;

  final List<String> _titles = [
    'Mappa',
    'Sfide',
    'Profilo',
    'Collezionabili',
    'Negozio',
  ];

  @override
  void initState() {
    super.initState();

    BalanceNotifier.I.refresh();

    _busSub = ChallengeEventBus.I.stream.listen((e) async {
      if (e is GoToMapForCharacterEvent) {
        _controller.jumpToTab(0);
        setState(() => _currentIndex = 0);
      }

      if (e is ChallengeCompletedEvent) {
        await BalanceNotifier.I.refresh();
      }
    });
  }

  @override
  void dispose() {
    _busSub?.cancel();
    super.dispose();
  }

  Future<void> logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    try {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      final result = await signOut().run();

      result.match(
        (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Logout fallito: $error')));
        },
        (_) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthenticationGate()),
            (_) => false,
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore inatteso: $e')));
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _controller.index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_controller.index != 0) {
          _controller.jumpToTab(0);
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          forceMaterialTransparency: true,

          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _titles[_currentIndex],
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 10),
            ],
          ),

          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ValueListenableBuilder<int>(
                valueListenable: BalanceNotifier.I.balance,
                builder: (_, value, _) => BalancePill(balance: value),
              ),
            ),
            if(_currentIndex == _profileTabIndex)
              IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
            const SizedBox(width: 6),
          ],
        ),
        body: PersistentTabView(
          controller: _controller,
          onTabChanged: (index) => setState(() => _currentIndex = index),
          tabs: [
            PersistentTabConfig(
              screen: const MapGate(),
              item: ItemConfig(
                icon: Icon(Icons.map),
                title: 'Mappa',
                activeForegroundColor: AppTheme.primaryColor,
              ),
            ),
            PersistentTabConfig(
              screen: const ChallengeGatePage(),
              item: ItemConfig(
                icon: Icon(Icons.emoji_flags_outlined),
                title: 'Sfide',
                activeForegroundColor: AppTheme.primaryColor,
              ),
            ),
            PersistentTabConfig(
              screen: const ProfileScreenState(),
              item: ItemConfig(
                icon: Icon(Icons.account_circle),
                title: 'Profilo',
                activeForegroundColor: AppTheme.primaryColor,
              ),
            ),
            PersistentTabConfig(
              screen: const CollectibleGate(),
              item: ItemConfig(
                icon: Icon(Icons.stars_sharp),
                title: 'Collezionabili',
                activeForegroundColor: AppTheme.primaryColor,
              ),
            ),
            PersistentTabConfig(
              screen: const ShopGate(),
              item: ItemConfig(
                icon: Icon(Icons.store),
                title: 'Negozio',
                activeForegroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
          navBarBuilder: (navBarConfig) =>
              Style2BottomNavBar(navBarConfig: navBarConfig),
        ),
      ),
    );
  }
}
