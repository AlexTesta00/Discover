import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingBuilder extends StatelessWidget {

  final String title;
  final String description;
  final String imagePath;

  const OnboardingBuilder({super.key, required this.title, required this.description, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.contain,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 24),
            Text(title, style: GoogleFonts.ptSerif(
              fontSize: 32, 
              fontWeight: FontWeight.bold
            ),
              textAlign: TextAlign.left
            ),
            const SizedBox(height: 12),
            Text(description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }
}