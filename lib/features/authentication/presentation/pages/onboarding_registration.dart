import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/domain/entities/registration_data.dart';
import 'package:discover/features/authentication/domain/use_cases/registration_service.dart';
import 'package:discover/features/authentication/presentation/widgets/avatar_step.dart';
import 'package:discover/features/authentication/presentation/widgets/email_step.dart';
import 'package:discover/features/authentication/presentation/widgets/password_step.dart';
import 'package:flutter/material.dart';
import '../widgets/progress_pills.dart';

class OnboardingRegistrationPage extends StatefulWidget {
  const OnboardingRegistrationPage({super.key});

  @override
  State<OnboardingRegistrationPage> createState() =>
      _OnboardingRegistrationPageState();
}

class _OnboardingRegistrationPageState
    extends State<OnboardingRegistrationPage> {
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

  Future<void> _next() async {
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

      //Register user
      setState(() => loading = true);

      final result = await signUpAndCreateProfile(
        email: data.email!,
        password: data.password!,
        avatarUrl: data.avatarKey!,
      ).run();

      if (!mounted) return;
      setState(() => loading = false);

      result.match(
        (err) => _snack('Errore durante la registrazione: $err'),
        (_) => _snack('Registrazione avvenuta con successo!'),
      );
      
      return;
    }
    setState(() => step += 1);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (step == 0) return;
    setState(() => step -= 1);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final isLast = step == 2;
    final nextLabel = isLast ? 'Crea account' : 'Prossimo step';

    return Scaffold(
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
                height: 50,
                child: ElevatedButton(onPressed: _next, child: Text(nextLabel)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: step == 0 ? null : _back,
                  child: const Text('Torna indietro'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: step == 0
                        ? Colors.grey
                        : AppTheme.primaryColor,
                    side: step == 0
                        ? BorderSide(color: Colors.grey)
                        : BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
