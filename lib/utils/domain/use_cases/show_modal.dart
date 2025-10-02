import 'package:discover/utils/presentation/widgets/success_modal.dart';
import 'package:flutter/material.dart';

Future<void> showSuccessModal(
  BuildContext context, {
  required String title,
  required String description,
  String buttonLabel = 'Okay',
  bool barrierDismissible = false,
  VoidCallback? onOk, // opzionale: callback dopo la chiusura
  Color iconBgColor = const Color(0xFF28C062), // verde check
  Color buttonColor = const Color(0xFFFF5B7C), // rosa bottone
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => SuccessModal(
      title: title,
      description: description,
      buttonLabel: buttonLabel,
      onOk: onOk,
      iconBgColor: iconBgColor,
      buttonColor: buttonColor,
    ),
  );
}