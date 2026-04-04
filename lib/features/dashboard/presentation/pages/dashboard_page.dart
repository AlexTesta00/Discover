import 'dart:async';
import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/authentication/presentation/state_management/authentication_gate.dart';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/presentation/pages/challenge_gate.dart';
import 'package:discover/features/dashboard/presentation/widgets/balance_pill.dart';
import 'package:discover/features/gamification/presentation/pages/collectable_gate.dart';
import 'package:discover/features/maps/presentation/controller/demo_tracking_controller.dart';
import 'package:discover/features/profile/presentation/state_management/profile_screen_state.dart';
import 'package:discover/features/shop/presentation/pages/shop_gate.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:discover/features/user/presentation/widgets/balance_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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
  String? _levelShort;
  final GlobalKey _rightKey = GlobalKey();
  double _sideWidth = 0;

  final List<String> _titles = ['Mappa', 'Sfide', 'Profilo', 'Collezionabili', 'Negozio'];

  @override
  void initState() {
    super.initState();

    BalanceNotifier.I.refresh();
    _loadLevel();

    _busSub = ChallengeEventBus.I.stream.listen((e) async {
      if (e is GoToMapForCharacterEvent) {
        _controller.jumpToTab(0);
        if (mounted) setState(() => _currentIndex = 0);
      }

      if (e is ChallengeCompletedEvent) {
        await BalanceNotifier.I.refresh();
        _loadLevel();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowTutorial());
  }

  Future<void> _maybeShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('dashboardTutorialShown') ?? false;
    if (shown || !mounted) return;
    _showTutorial();
  }

  TutorialCoachMark? _tutorial;

  void _showTutorial() {
    bool isLast(int index) => index == 4;

    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    // viewPadding gives the real system bottom inset regardless of Scaffold
    final bottomInset = mq.viewPadding.bottom;
    const navBarHeight = 56.0;
    final navTop = screenHeight - navBarHeight - bottomInset;

    // Style2BottomNavBar: active item = 29% of screen width, inactive = 12%
    // Layout: MainAxisAlignment.spaceAround with 5 items (tab 0 active at tutorial start)
    const double activeWFrac = 0.29;
    const double inactiveWFrac = 0.12;
    const int tabCount = 5;
    final double totalItemW = (activeWFrac + (tabCount - 1) * inactiveWFrac) * screenWidth;
    final double gap = (screenWidth - totalItemW) / tabCount; // spaceAround spacing

    Offset tabOffset(int i) {
      if (i == 0) return Offset(gap / 2, navTop);
      final left = gap / 2 + activeWFrac * screenWidth + i * gap + (i - 1) * inactiveWFrac * screenWidth;
      return Offset(left, navTop);
    }

    Size tabSize(int i) => Size(i == 0 ? activeWFrac * screenWidth : inactiveWFrac * screenWidth, navBarHeight);

    TargetFocus buildTarget({
      required String id,
      required int index,
      required IconData icon,
      required String title,
      required String description,
    }) {
      return TargetFocus(
        identify: id,
        targetPosition: TargetPosition(tabSize(index), tabOffset(index)),
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: _TutorialContent(
              icon: icon,
              title: title,
              description: description,
              isLast: isLast(index),
              onNext: () => isLast(index) ? _tutorial?.finish() : _tutorial?.next(),
              onSkip: () => _tutorial?.skip(),
            ),
          ),
        ],
      );
    }

    final targets = [
      buildTarget(
        id: 'tab_mappa',
        index: 0,
        icon: Icons.map,
        title: 'Mappa',
        description: 'Esplora il Parco del Delta del Po, trova i personaggi e raggiungili per completare le sfide.',
      ),
      buildTarget(
        id: 'tab_sfide',
        index: 1,
        icon: Icons.emoji_flags_outlined,
        title: 'Sfide',
        description: 'Visualizza tutte le sfide disponibili. Fotografa gli animali giusti o parla con i personaggi per completarle.',
      ),
      buildTarget(
        id: 'tab_profilo',
        index: 2,
        icon: Icons.account_circle,
        title: 'Profilo',
        description: 'Guarda il tuo livello, i tuoi progressi e le foto delle sfide completate. Puoi anche aggiungere amici.',
      ),
      buildTarget(
        id: 'tab_collezionabili',
        index: 3,
        icon: Icons.stars_sharp,
        title: 'Collezionabili',
        description: 'Sblocca sticker unici completando tutte le sfide di un personaggio. Collezionali tutti!',
      ),
      buildTarget(
        id: 'tab_negozio',
        index: 4,
        icon: Icons.store,
        title: 'Negozio',
        description: 'Spendi i Fenicotteri guadagnati per acquistare nuovi avatar e sfondi per il tuo profilo.',
      ),
    ];

    _tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFFEF4565),
      opacityShadow: 0.75,
      paddingFocus: 8,
      skipWidget: const SizedBox.shrink(),
      onFinish: _saveTutorialShown,
      onSkip: () {
        _saveTutorialShown();
        return true;
      },
    )..show(context: context);
  }

  Future<void> _saveTutorialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dashboardTutorialShown', true);
  }

  Future<void> _loadLevel() async {
    try {
      final level = await getMyLevel();
      if (!mounted) return;
      setState(() {
        _levelShort = 'Liv.${level?.grade ?? 0}';
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossibile caricare il livello')));
    }
  }

  void _measureRight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final w = _rightKey.currentContext?.size?.width ?? 0;
      if (!mounted) return;
      if (w != _sideWidth) setState(() => _sideWidth = w);
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout fallito: $error')));
        },
        (_) {
          if (!mounted) return;
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthenticationGate()), (_) => false);
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore inatteso: $e')));
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _measureRight();

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          forceMaterialTransparency: true,
          title: Row(
            children: [
              SizedBox(
                width: _sideWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: (_levelShort != null && _currentIndex != _profileTabIndex)
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              _levelShort!,
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _titles[_currentIndex],
                    style: const TextStyle(color: Colors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IntrinsicWidth(
                child: Container(
                  key: _rightKey,
                  padding: const EdgeInsets.only(right: 6),
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: BalanceNotifier.I.balance,
                        builder: (_, value, _) => BalancePill(balance: value),
                      ),
                      if (_currentIndex == _profileTabIndex)
                        IconButton(
                          onPressed: logout,
                          icon: const Icon(Icons.logout, color: Colors.black),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: PersistentTabView(
          controller: _controller,
          onTabChanged: (index) => setState(() => _currentIndex = index),
          handleAndroidBackButtonPress: false,
          tabs: [
            PersistentTabConfig(
              screen: const MapDemoGate(),
              item: ItemConfig(icon: const Icon(Icons.map), title: 'Mappa', activeForegroundColor: AppTheme.primaryColor),
            ),
            PersistentTabConfig(
              screen: const ChallengeGatePage(),
              item: ItemConfig(icon: const Icon(Icons.emoji_flags_outlined), title: 'Sfide', activeForegroundColor: AppTheme.primaryColor),
            ),
            PersistentTabConfig(
              screen: const ProfileScreenState(),
              item: ItemConfig(icon: const Icon(Icons.account_circle), title: 'Profilo', activeForegroundColor: AppTheme.primaryColor),
            ),
            PersistentTabConfig(
              screen: const CollectibleGate(),
              item: ItemConfig(icon: const Icon(Icons.stars_sharp), title: 'Collezionabili', activeForegroundColor: AppTheme.primaryColor),
            ),
            PersistentTabConfig(
              screen: const ShopGate(),
              item: ItemConfig(icon: const Icon(Icons.store), title: 'Negozio', activeForegroundColor: AppTheme.primaryColor),
            ),
          ],
          navBarBuilder: (navBarConfig) => Style2BottomNavBar(navBarConfig: navBarConfig),
        ),
      ),
    );
  }
}

class _TutorialContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TutorialContent({
    required this.icon,
    required this.title,
    required this.description,
    required this.isLast,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(description, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isLast)
              ElevatedButton(
                onPressed: onSkip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text('Salta', style: TextStyle(fontWeight: FontWeight.w700)),
              )
            else
              const SizedBox.shrink(),
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: Text(isLast ? 'Inizia!' : 'Avanti', style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }
}
