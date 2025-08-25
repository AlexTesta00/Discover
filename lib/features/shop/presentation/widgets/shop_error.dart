import 'package:flutter/material.dart';

class ShopError extends StatelessWidget {
  const ShopError({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        FilledButton(onPressed: onRetry, child: const Text('Riprova')),
      ]),
    );
  }
}
