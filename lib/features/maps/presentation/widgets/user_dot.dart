import 'package:flutter/material.dart';

class UserDot extends StatelessWidget {
  const UserDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // // Big background circle
        // Container(
        //   width: 30,
        //   height: 30,
        //   decoration: BoxDecoration(
        //     color: Colors.blue.withOpacity(0.2),
        //     shape: BoxShape.circle,
        //   ),
        // ),
        // White circle
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        // Blu central point
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}