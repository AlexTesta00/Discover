import 'package:flutter/material.dart';

class ErrorModal extends StatelessWidget {
  final String message;

  const ErrorModal({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Errore',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}