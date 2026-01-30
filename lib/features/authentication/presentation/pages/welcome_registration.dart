import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/authentication/presentation/pages/authentication_page.dart';
import 'package:discover/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:discover/features/authentication/presentation/pages/onboarding_registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WelcomeRegistration extends StatefulWidget {
  const WelcomeRegistration({super.key});

  @override
  State<WelcomeRegistration> createState() => _WelcomeRegistrationState();
}

class _WelcomeRegistrationState extends State<WelcomeRegistration> {
  bool _loading = false;

  void _goBackToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthenticationPage()),
    );
  }

  Future<void> loginWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final webClientId = dotenv.env['WEB_CLIENT_ID'] ?? '';
      final iosClientId = dotenv.env['IOS_CLIENT_ID'] ?? '';

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId.isEmpty ? null : webClientId,
        clientId: iosClientId.isEmpty ? null : iosClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) return;

      final result = await signInWithGoogle(idToken, accessToken).run();

      result.match(
        (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        },
        (response) async {
          if (!mounted) return;
          final session =
              response.session ?? Supabase.instance.client.auth.currentSession;
          final ensure = await ensureProfileFromCurrentUser().run();
          ensure.match(
            (e) {
              debugPrint('Errore ensure, $e');
            },
            (_) {
              debugPrint('Ensure completed');
            },
          );
          if (session != null) {
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DashboardPage()),
              (_) => false,
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Login Google eseguito, ma nessuna sessione attiva.',
                ),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore inatteso: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBackToLogin();
      },
      child: Scaffold(
        body: SafeArea(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // immagine
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Center(
                      child: Image.asset(
                        'assets/icons/dark_matter.gif',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
      
                  const SizedBox(height: 24),
      
                  // testi e bottoni
                  Column(
                    children: [
                      const Text(
                        'Benvenuto',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Il tuo viaggio inizia qui',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
      
                      // bottone registrati con telefono
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const OnboardingRegistrationPage(),
                              ),
                              (_) => false,
                            );
                          },
                          child: const Text(
                            'Registrati con il telefono',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
      
                      const SizedBox(height: 16),
      
                      // bottone Google
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _loading ? null : loginWithGoogle,
                          icon: _loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Image.asset(
                                  'assets/icons/google_logo.webp',
                                  height: 24,
                                  width: 24,
                                ),
                          label: Text(
                            _loading
                                ? 'Accesso in corso...'
                                : 'Continua con Google',
                            style: const TextStyle(color: Colors.black),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
