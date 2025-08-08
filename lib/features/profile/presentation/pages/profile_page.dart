import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/profile/presentation/widgets/info_card.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profilo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2F7C6E)),
        scaffoldBackgroundColor: const Color(0xFFF6F3EF),
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.creamColor,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 220,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/liquid.jpeg',
                        ),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -80,
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8))
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const CircleAvatar(
                            backgroundImage: AssetImage('assets/images/profile-default-avatar.jpg'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'mario.rossi@gmail.com',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 96),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: .94,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: const [
                    InfoCard(
                      title: 'Livello',
                      subtitle: 'Avventuriero',
                      assetImagePath: 'assets/icons/binoculars.png',
                    ),
                    InfoCard(
                      title: 'Prossimo Livello',
                      subtitle: 'Ricercatore',
                      assetImagePath: 'assets/icons/research.png',
                    ),
                    InfoCard(
                      title: 'Fenicotteri',
                      subtitle: '157',
                      assetImagePath: 'assets/icons/flamingo.png',
                    ),
                    InfoCard(
                      title: 'Punti Esperienza',
                      subtitle: '1250',
                      assetImagePath: 'assets/icons/upgrade.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}