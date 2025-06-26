import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/presentation/pages/authentication_page.dart';
import 'package:discover/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2YXZkaWJwYXJid2d1dWlmdHJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA2ODg0OTMsImV4cCI6MjA2NjI2NDQ5M30.Wx4ti4pmTMa7dVVROEMIwDMgQVfQD6EbThj7fA-S-pQ',
    url: 'https://xvavdibparbwguuiftrs.supabase.co',
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  final isFirstRun = sharedPreferences.getBool('onBoardingComplete') ?? true;

  runApp(MyApp(isFirstRun: isFirstRun));
}

class MyApp extends StatelessWidget {

  final bool isFirstRun;

  const MyApp({super.key, required this.isFirstRun});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: isFirstRun ? const OnBoardingScreen() : const AuthenticationPage(),
    );
  }
}