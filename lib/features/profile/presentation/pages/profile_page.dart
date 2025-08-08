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
                                  color: Colors.black.withValues(alpha: 0.08),
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
                      description: "Il livello indica quanto sei esperto e familiare con il parco in questo momento. Più esplori e ti metti in gioco, più crescerà! Completando missioni oppure visitando punti di interesse lungo gli itinerari che puoi creare nella sezione Itinerari, guadagnerai punti esperienza. Ogni volta che accumuli abbastanza punti, il tuo grado di confidenza con il parco aumenterà, permettendoti di conoscerne sempre meglio segreti, curiosità e luoghi speciali.",
                    ),
                    InfoCard(
                      title: 'Prossimo Livello',
                      subtitle: 'Ricercatore',
                      assetImagePath: 'assets/icons/research.png',
                      description: "Il prossimo livello rappresenta il traguardo che ti aspetta: un nuovo grado di confidenza con il parco, che potrai raggiungere accumulando punti esperienza. Per avvicinarti a questo obiettivo, esplora, completa missioni e percorri itinerari: ogni passo, ogni scoperta e ogni sfida superata ti farà guadagnare punti, avvicinandoti sempre di più al tuo prossimo livello di esploratore.",
                    ),
                    InfoCard(
                      title: 'Fenicotteri',
                      subtitle: '157',
                      assetImagePath: 'assets/icons/flamingo.png',
                      description: "I fenicotteri sono la moneta speciale del parco: più esplori, ti avventuri tra i sentieri e completi missioni, più ne accumulerai. Ogni fenicottero che guadagni è prezioso, perché potrai usarlo per acquistare collezionabili unici nel negozio del parco oppure per ottenere sconti esclusivi nei vari punti vendita. In poche parole, più vivi il parco, più ricompense e vantaggi potrai ottenere!",
                    ),
                    InfoCard(
                      title: 'Punti Esperienza',
                      subtitle: '1250',
                      assetImagePath: 'assets/icons/upgrade.png',
                      description: "I punti esperienza sono il cuore del tuo percorso per diventare un vero ricercatore avanzato del parco. Ogni volta che li guadagni, compiendo missioni, esplorando nuovi angoli o scoprendo curiosità, aumenti il tuo grado di confidenza con l’ambiente che ti circonda. Più punti accumuli, più la tua conoscenza e la tua familiarità con il parco cresceranno, permettendoti di viverlo con occhi sempre più esperti e curiosi.",
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