import 'package:discover/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'step_scaffold.dart';

class EmailStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  const EmailStep({super.key, required this.formKey, required this.controller});

  @override
  Widget build(BuildContext context) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    
    return StepScaffold(
      title: 'Qual è la tua email?',
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: AppTheme.inputDecoration('mario.rossi@example.com'),
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return 'L’email è obbligatoria';
            if (!emailRegex.hasMatch(v)) return 'Inserisci un’email valida';
            return null;
          },
        ),
      ),
    );
  }
}
