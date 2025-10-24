import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/authentication/presentation/state_management/authentication_gate.dart';
import 'package:discover/features/challenge/presentation/pages/challenge_gate.dart';
import 'package:discover/features/events/domain/use_cases/event_service.dart';
import 'package:discover/features/events/presentation/pages/feed_gate.dart';
import 'package:discover/features/friendship/presentation/state_management/friendship_gate.dart';
import 'package:discover/features/maps/presentation/pages/map_gate.dart';
import 'package:discover/features/profile/presentation/state_management/profile_screen_state.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
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

  final List<String> _titles = [
    'Mappa',
    'Challenge',
    'Profilo',
    'Amici',
    'Feed',
  ];

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
        },
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
              title: 'Challenge',
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
            screen: const FriendshipGate(),
            item: ItemConfig(
              icon: Icon(Icons.group),
              title: 'Amici',
              activeForegroundColor: AppTheme.primaryColor,
            ),
          ),
          PersistentTabConfig(
            screen: FeedGate(
              getEventsFeed: ({limit = 50, offset = 0}) =>
                  getEventsFeed(limit: limit, offset: offset),
              getUserByEmail: getUserByEmail,
              pageSize: 20,
            ),
            item: ItemConfig(
              icon: Icon(Icons.feed),
              title: 'Feed',
              activeForegroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) =>
            Style2BottomNavBar(navBarConfig: navBarConfig),
      ),
    );
  }
}
