import 'package:discover/config/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ProgressPills extends StatelessWidget {
  final int total;
  final int current;
  final Color activeColor;
  final Color inactiveColor;

  const ProgressPills({
    super.key,
    required this.total,
    required this.current,
    this.activeColor = AppTheme.primaryColor,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Container(
          margin: EdgeInsets.only(right: i == total - 1 ? 0 : 8),
          width: 32,
          height: 8,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}
