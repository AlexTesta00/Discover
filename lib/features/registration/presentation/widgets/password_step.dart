import 'package:discover/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import '../widgets/step_scaffold.dart';

class PasswordStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController pwdCtrl;
  final TextEditingController pwd2Ctrl;
  const PasswordStep({
    super.key,
    required this.formKey,
    required this.pwdCtrl,
    required this.pwd2Ctrl,
  });

  @override
  State<PasswordStep> createState() => _PasswordStepState();
}

class _PasswordStepState extends State<PasswordStep> {
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return StepScaffold(
      title: 'Scegli una password?',
      child: Form(
        key: widget.formKey,
        child: Column(
          children: [
            TextFormField(
              controller: widget.pwdCtrl,
              obscureText: _obscure1,
              autofillHints: const [AutofillHints.newPassword],
              decoration: AppTheme.inputDecoration('Digita la password').copyWith(
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                  icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (s) {
                final v = s ?? '';
                if (v.isEmpty) return 'La password è obbligatoria';
                if (v.length < 8) return 'Minimo 8 caratteri';
                final hasNum = RegExp(r'\d').hasMatch(v);
                final hasLet = RegExp(r'[A-Za-z]').hasMatch(v);
                if (!hasNum || !hasLet) return 'Usa lettere e numeri';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: widget.pwd2Ctrl,
              obscureText: _obscure2,
              autofillHints: const [AutofillHints.newPassword],
              decoration: AppTheme.inputDecoration('Conferma password').copyWith(
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                  icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Conferma la password';
                if (v != widget.pwdCtrl.text) return 'Le password non coincidono';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
