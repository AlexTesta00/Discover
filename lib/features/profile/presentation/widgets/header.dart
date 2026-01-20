import 'dart:math' as math;
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.headerImage,
    required this.avatarImage,
    required this.shadow,
    this.progress = 0.0,
    this.ringColor,
    this.ringThickness = 8.0,
    this.ringSize = 128.0,
  });

  final String? headerImage;
  final String? avatarImage;
  final List<BoxShadow> shadow;

  // nuovo
  final double progress;
  final Color? ringColor;
  final double ringThickness;
  final double ringSize;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    const toolbar = kToolbarHeight;
    const visibleContent = 160.0;
    final headerHeight = topInset + toolbar + visibleContent;

    final effectiveColor = ringColor ?? Theme.of(context).colorScheme.primary;
    final clamped = progress.clamp(0.0, 1.0);

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          Image.asset(
            headerImage ?? 'assets/background/default.png',
            fit: BoxFit.cover,
          ),

          // avatar + progress ring
          Positioned(
            bottom: -36,
            child: SizedBox(
              width: ringSize,
              height: ringSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: ringSize,
                    height: ringSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: ringThickness,
                        color: effectiveColor.withValues(alpha: 0.18),
                      ),
                    ),
                  ),

                  // anello di progresso
                  Positioned.fill(
                    child: Transform.rotate(
                      angle: - math.pi * 2,
                      child: CircularProgressIndicator(
                        value: clamped,
                        strokeWidth: ringThickness,
                        valueColor: AlwaysStoppedAnimation(effectiveColor),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),

                  // avatar
                  Container(
                    width: ringSize - ringThickness * 2,
                    height: ringSize - ringThickness * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                      boxShadow: shadow,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: Image.asset(
                        avatarImage ?? 'assets/avatar/avatar_9.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
