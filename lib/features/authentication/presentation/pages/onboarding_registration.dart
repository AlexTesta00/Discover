import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/domain/entities/registration_data.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/authentication/presentation/pages/welcome_registration.dart';
import 'package:discover/features/authentication/presentation/state_management/authentication_gate.dart';
import 'package:discover/features/authentication/presentation/widgets/avatar_step.dart';
import 'package:discover/features/authentication/presentation/widgets/email_step.dart';
import 'package:discover/features/authentication/presentation/widgets/password_step.dart';
import 'package:discover/utils/domain/use_cases/show_modal.dart';
import 'package:flutter/material.dart';
import '../widgets/progress_pills.dart';

class OnboardingRegistrationPage extends StatefulWidget {
  const OnboardingRegistrationPage({super.key});

  @override
  State<OnboardingRegistrationPage> createState() =>
      _OnboardingRegistrationPageState();
}

class _OnboardingRegistrationPageState extends State<OnboardingRegistrationPage> {
  final _pageController = PageController();
  final _emailKey = GlobalKey<FormState>();
  final _pwdKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();

  final data = RegistrationData();
  int step = 0;
  bool loading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _goToStep(int newStep) {
    setState(() => step = newStep);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> _next() async {
    if (loading) return;

    if (step == 0) {
      if (_emailKey.currentState?.validate() != true) return;
      data.email = _emailCtrl.text.trim();
    } else if (step == 1) {
      if (_pwdKey.currentState?.validate() != true) return;
      data.password = _pwdCtrl.text;
    } else if (step == 2) {
      if (data.avatarKey == null) {
        _snack('Seleziona un avatar per continuare');
        return;
      }

      setState(() => loading = true);

      final result = await signUpAndCreateProfile(
        email: data.email!,
        password: data.password!,
        avatarUrl: data.avatarKey!,
      ).run();

      if (!mounted) return;
      setState(() => loading = false);

      await result.match(
        (err) async {
          _snack('Errore durante la registrazione: $err');
        },
        (_) async {
          await showSuccessModal(
            context,
            title: 'Congratulazioni!',
            description: 'Hai creato il tuo account con successo',
          );

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthenticationGate()),
          );
        },
      );

      return;
    }

    _goToStep(step + 1);
  }

  void _back() {
    if (step == 0) return;
    _goToStep(step - 1);
  }

  void _handleBack() {
    if (step == 0) {
      // Torna alla pagina WelcomeRegistration (quella che mi hai incollato)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeRegistration()),
      );
    } else {
      _back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
    final nextLabel = isLast ? 'Crea account' : 'Prossimo step';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ProgressPills(total: 3, current: step),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      EmailStep(formKey: _emailKey, controller: _emailCtrl),
                      PasswordStep(
                        formKey: _pwdKey,
                        pwdCtrl: _pwdCtrl,
                        pwd2Ctrl: _pwd2Ctrl,
                      ),
                      AvatarStep(
                        selectedKey: data.avatarKey,
                        onSelect: (k) => setState(() => data.avatarKey = k),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _next,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(loading ? 'Caricamento...' : nextLabel),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: step == 0
                          ? AppTheme.primaryColor
                          : AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(step == 0 ? 'Torna alla welcome' : 'Torna indietro'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
