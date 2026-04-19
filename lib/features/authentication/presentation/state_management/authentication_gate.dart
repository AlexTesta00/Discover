import 'dart:async';

import 'package:discover/features/authentication/presentation/pages/authentication_page.dart';
import 'package:discover/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({super.key});

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<AuthenticationGate> {
  late bool _loggedIn;
  StreamSubscription<AuthState>? _sub;

  @override
  void initState() {
    super.initState();
    // Legge la sessione corrente senza aspettare il primo evento stream
    _loggedIn = Supabase.instance.client.auth.currentSession != null;

    // Si aggiorna SOLO quando lo stato logged-in/logged-out cambia davvero.
    // Token refresh e altri eventi intermedi vengono ignorati.
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((state) {
      final isLoggedIn = state.session != null;
      if (isLoggedIn != _loggedIn && mounted) {
        setState(() => _loggedIn = isLoggedIn);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _loggedIn ? const DashboardPage() : const AuthenticationPage();
  }
}