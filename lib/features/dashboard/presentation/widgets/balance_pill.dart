import 'package:flutter/material.dart';

class BalancePill extends StatelessWidget {
  final int balance;
  const BalancePill({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F6F2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/foreground.png',
            width: 12,
            height: 12,
          ),
          const SizedBox(width: 6),
          Text(
            '$balance',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
