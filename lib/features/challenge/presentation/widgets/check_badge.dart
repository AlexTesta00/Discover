import 'package:discover/config/themes/app_theme.dart';
import 'package:flutter/material.dart';

class CheckBadge extends StatelessWidget {
  final bool isChecked;
  const CheckBadge({super.key, required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isChecked
          ? Container(
              key: const ValueKey('checked'),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: AppTheme.primaryColor),
            )
          : const SizedBox(key: ValueKey('unchecked'), width: 36, height: 36),
    );
  }
}
