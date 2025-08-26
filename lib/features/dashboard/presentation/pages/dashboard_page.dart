import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/authentication/presentation/state_management/authentication_gate.dart';
import 'package:discover/features/challenge/presentation/pages/challenge_page.dart';
import 'package:discover/features/maps/presentation/pages/itinerary_page.dart';
import 'package:discover/features/news/presentation/pages/news_page.dart';
import 'package:discover/features/notices/presentation/pages/notices_page.dart';
import 'package:discover/features/profile/presentation/pages/profile_page.dart';
import 'package:discover/features/shop/presentation/pages/shop_page.dart';
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
  bool _loggingOut = false;
  final GlobalKey<ShopPageState> _shopKey = GlobalKey<ShopPageState>();
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey<ProfileScreenState>();

  final List<String> _titles = [
    'Itinerario',
    'Challenge',
    'News',
    'Avvisi',
    'Negozio',
    'Profilo',
  ];

  Future<void> logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);

    try {
      try { await GoogleSignIn().signOut(); } catch (_) {}

      final result = await signOut().run();

      result.match(
        (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout fallito: $error')),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore inatteso: $e')),
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _titles[_currentIndex], 
            style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: PersistentTabView(
        onTabChanged: (index) async {
          setState(() {
            _currentIndex = index;
          });

          if (index == 3) {
            _shopKey.currentState?.refreshFromOutside();
          }

          if (index == 4) {
            await _profileKey.currentState?.reloadVisualsFromPrefs();
          }
        },
        tabs: [
          PersistentTabConfig(
            screen: const ItineraryPage(), 
            item: ItemConfig(
                icon: Icon(Icons.follow_the_signs_rounded),
                title: 'Itinerario',
                activeForegroundColor: AppTheme.primaryColor
              )
            ),
          PersistentTabConfig(
            screen: const ChallengesPage(), 
            item: ItemConfig(
              icon: Icon(Icons.emoji_events_rounded),
              title: 'Challenge',
              activeForegroundColor: AppTheme.primaryColor
            )
          ),
          PersistentTabConfig(
            screen: const NewsPage(), 
            item: ItemConfig(
              icon: Icon(Icons.newspaper),
              title: 'News',
              activeForegroundColor: AppTheme.primaryColor
            )
          ),
          PersistentTabConfig(
            screen: const NoticesPage(), 
            item: ItemConfig(
              icon: Icon(Icons.notifications_active),
              title: 'Avvisi',
              activeForegroundColor: AppTheme.primaryColor
            )
          ),
          PersistentTabConfig(
            screen: ShopPage(key: _shopKey),
            item: ItemConfig(
              icon: Icon(Icons.store),
              title: 'Negozio',
              activeForegroundColor: AppTheme.primaryColor
            )
          ), 
          PersistentTabConfig(
            screen: ProfileScreen(key: _profileKey),
            item: ItemConfig(
              icon: Icon(Icons.account_circle),
              title: 'Profilo',
              activeForegroundColor: AppTheme.primaryColor
            )
          ),
        ], 
        navBarBuilder: (navBarConfig) => Style2BottomNavBar(
          navBarConfig: navBarConfig
          ),
        ),
    );
  }
}