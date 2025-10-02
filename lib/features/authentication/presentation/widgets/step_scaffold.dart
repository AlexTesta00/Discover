import 'dart:math' as math;
import 'package:flutter/material.dart';

class StepScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const StepScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final edge = 16.0;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom; // tastiera

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: edge,
              right: edge,
              bottom: math.max(edge, bottomInset),
              top: edge,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  child,
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
