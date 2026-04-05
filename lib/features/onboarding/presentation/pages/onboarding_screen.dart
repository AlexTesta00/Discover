import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/onboarding/presentation/pages/finish_on_boarding.dart';
import 'package:discover/features/onboarding/presentation/widgets/onboarding_builder.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  static const _numberOfPages = 3;
  bool _onLastPage = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => {
              setState(() {
                _onLastPage = (index == _numberOfPages - 1);
              }),
            },
            children: [
              OnboardingBuilder(
                title: 'Il\nProgetto\nDiscover',
                description:
                    "Discover è un'app per esplorare il Parco del Delta del Po: uno degli ecosistemi più ricchi d'Europa. Incontra i suoi abitanti, scopri la biodiversità del territorio e vivi il parco in modo nuovo.",
                imagePath: 'assets/images/fenicottero_3d.webp',
              ),
              OnboardingBuilder(
                title: 'Citizen\nScience',
                description:
                    "Ogni foto che scatti e ogni sfida che completi contribuisce attivamente alla ricerca scientifica. Le tue osservazioni diventano dati reali per monitorare la salute dell'ecosistema del Delta del Po.",
                imagePath: 'assets/images/ricerca_3d.webp',
              ),
              OnboardingBuilder(
                title: 'Il Tuo\nObiettivo',
                description:
                    "Raggiungi i personaggi sulla mappa, completa le sfide fotografiche e guadagna fenicotteri. Sali di livello, sblocca sticker nell'Album e conosci da vicino gli animali del parco.",
                imagePath: 'assets/images/citizen_3d.webp',
              ),
            ],
          ),

          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => _controller.jumpToPage(2),
                  child: Text('Salta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: _numberOfPages,
                  effect: const ExpandingDotsEffect(dotColor: Colors.black38, activeDotColor: AppTheme.primaryColor),
                ),
                _onLastPage
                    ? GestureDetector(
                        onTap: () async {
                          final preference = await SharedPreferences.getInstance();
                          await preference.setBool('onBoardingComplete', true);

                          if (!context.mounted) return;

                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const FinishOnBoarding()));
                        },
                        child: Text(
                          'Inizia!',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn),
                        child: Text('Avanti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
