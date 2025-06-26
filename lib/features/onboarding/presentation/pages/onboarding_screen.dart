import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/authentication/presentation/state_management/authentication_gate.dart';
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
              })
            },
            children: [
              OnboardingBuilder(
                title: 'Il\nProgetto\nDiscover',
                description: 'Il progetto Discover nasce dall\'idea di creare un\'applicazione che permetta agli utenti di scoprire e condividere luoghi interessanti.',
                imagePath: 'assets/images/fenicottero_3d.png',
              ),
              OnboardingBuilder(
                title: 'Ricerca\nSviluppo\nSostenibilità',
                description: 'Il progetto discover nasce dall’esigenza di fare qualcosa, in modo carino e confortevole senza che nessun animale venga maltrattato, sopratutto quei fenicotteri che sembrano sensibili a qualsiasi cosa, e sembra che sappiano cosa sono delle telecamere e vivono costantemente in un truman show',
                imagePath: 'assets/images/ricerca_3d.png',
              ),
              OnboardingBuilder(
                title: 'Citizen\nAnd\nScience',
                description: 'Il progetto discover nasce dall’esigenza di fare qualcosa, in modo carino e confortevole senza che nessun animale venga maltrattato, sopratutto quei fenicotteri che sembrano sensibili a qualsiasi cosa, e sembra che sappiano cosa sono delle telecamere e vivono costantemente in un truman show',
                imagePath: 'assets/images/citizen_3d.png',
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
                  child: Text('Skip')
                ),
                SmoothPageIndicator(
                  controller: _controller, 
                  count: _numberOfPages,
                  effect: const ExpandingDotsEffect(
                      dotColor: Colors.black38,
                      activeDotColor: AppTheme.primaryColor,
                  ),
                ),
                _onLastPage ?
                GestureDetector(
                  onTap: () async {
                    final preference = await SharedPreferences.getInstance();
                    await preference.setBool('onBoardingComplete', true);
                    
                    if(!mounted) return;

                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(
                        builder: (context) => const AuthenticationGate()
                      ),
                    );
                  },
                  child: Text('Done'),
                ) :
                GestureDetector(
                  onTap: () => _controller.nextPage(
                      duration: Duration(milliseconds: 500), 
                      curve: Curves.easeIn
                    ),
                  child: Text('Next')
                ),
              ],
            )
          )
        ],
      ),
    );
  }
}