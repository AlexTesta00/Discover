import 'package:discover/features/challenge/presentation/pages/challenge_gate.dart';
import 'package:flutter/material.dart';

class ChallengeFilterBar extends StatelessWidget {
  const ChallengeFilterBar({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final ChallengeFilter current;
  final ValueChanged<ChallengeFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          label: 'Tutte',
          active: current == ChallengeFilter.all,
          onTap: () => onChanged(ChallengeFilter.all),
        ),
        const SizedBox(width: 8),
        _Pill(
          label: 'Da fare',
          active: current == ChallengeFilter.todo,
          onTap: () => onChanged(ChallengeFilter.todo),
        ),
        const SizedBox(width: 8),
        _Pill(
          label: 'Completate',
          active: current == ChallengeFilter.done,
          onTap: () => onChanged(ChallengeFilter.done),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFF34E6C);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: active ? Colors.transparent : Colors.black26),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
