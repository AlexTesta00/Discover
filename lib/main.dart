import 'package:discover/app/route_observer.dart';
import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/presentation/pages/authentication_page.dart';
import 'package:discover/features/onboarding/presentation/pages/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('it_IT', null);
  await Supabase.initialize(
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    url: dotenv.env['SUPABASE_URL'] ?? '',
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  final isFirstRun = sharedPreferences.getBool('onBoardingComplete') ?? false;

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
      navigatorObservers: [routeObserver],
    );
  }
}