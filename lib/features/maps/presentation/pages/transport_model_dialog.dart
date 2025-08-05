import 'package:flutter/material.dart';

class TransportModeDialog extends StatelessWidget {
  final VoidCallback onWalkingSelected;
  final VoidCallback onCyclingSelected;

  const TransportModeDialog({
    Key? key,
    required this.onWalkingSelected,
    required this.onCyclingSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Seleziona modalità di viaggio"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onWalkingSelected();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/walking.png", width: 80),
                const SizedBox(height: 8),
                const Text("A Piedi"),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              onCyclingSelected();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/cycling.png", width: 80),
                const SizedBox(height: 8),
                const Text("In Bici"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
