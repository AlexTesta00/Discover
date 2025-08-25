import 'dart:async';
import 'package:discover/core/app_service.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/gamification/domain/use_case/user_service.dart';
import 'package:flutter/material.dart';
import 'package:discover/config/themes/app_theme.dart';
import 'package:discover/features/profile/presentation/widgets/info_card.dart';
import 'package:discover/features/profile/presentation/widgets/level_up_dialog.dart';
import 'package:discover/features/gamification/domain/entities/user.dart';
import 'package:discover/features/gamification/utils.dart';
import 'package:discover/features/shop/domain/repository/shop_prefs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  // UserService condiviso
  final _service = AppServices.userService;

  StreamSubscription<UserEvent>? _sub;

  User? _user;
  bool _loading = true;
  String? _email;
  String? _error;

  // evita multipli dialog di level-up
  bool _levelUpDialogOpen = false;

  // avatar/sfondo scelti
  String _bgAsset = ShopPrefs.defaultBackground;
  String _avatarAsset = ShopPrefs.defaultAvatar;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    _loadVisuals(); // carica avatar/sfondo salvati
  }

  Future<void> _bootstrap() async {
    try {
      _email = getUserEmail();
      if ((_email ?? '').isEmpty) {
        setState(() {
          _error = 'Email non presente';
          _loading = false;
        });
        return;
      }

      // crea/recupera l’utente
      final u = await _service.getOrCreate(email: _email);
      setState(() {
        _user = u;
        _loading = false;
      });

      // ascolta eventi (XP/LevelUp/Flamingo) e aggiorna UI
      _sub = _service.events.listen((evt) async {
        if (evt.email != _email) return;

        // ricarica i dati utente
        final refreshed = await _service.getUserData(_email!);
        if (mounted) setState(() => _user = refreshed);

        // se è un level-up, mostra il modale
        if (evt is LevelUp) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          await _showLevelUpDialog(evt);
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Errore durante il caricamento: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadVisuals() async {
    try {
      final bg = await ShopPrefs.getBackground();
      final av = await ShopPrefs.getAvatar();
      if (!mounted) return;
      setState(() {
        _bgAsset = bg;
        _avatarAsset = av;
      });
    } catch (_) {
      // fallback già impostati
    }
  }

  /// Chiamata dalla Dashboard quando la tab Profilo diventa attiva
  Future<void> reloadVisualsFromPrefs() async {
    await _loadVisuals();
  }

  double _levelProgress(User? u) {
    if (u == null) return 0.0;
    final next = u.nextLevel;
    if (next == null) return 1.0;

    final curBase = u.currentLevel.xpToReachLevel;
    final nextXp = next.xpToReachLevel;
    final span = nextXp - curBase;
    if (span <= 0) return 0.0;

    final gained = (u.xpReached - curBase).clamp(0, span);
    return gained / span;
  }

  int _xpToNext(User? u) {
    if (u == null) return 0;
    final next = u.nextLevel;
    if (next == null) return 0;
    final remaining = next.xpToReachLevel - u.xpReached;
    return remaining > 0 ? remaining : 0;
  }

  String _levelImageFor(String levelName) {
    try {
      final lvl = _user?.levels.firstWhere((l) => l.name == levelName);
      if (lvl != null && lvl.imageUrl.isNotEmpty) return lvl.imageUrl;
    } catch (_) {}
    return 'assets/icons/upgrade.png';
  }

  Future<void> _showLevelUpDialog(LevelUp evt) async {
    if (!mounted || _levelUpDialogOpen) return;
    _levelUpDialogOpen = true;

    final imagePath = _levelImageFor(evt.toLevelName);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return LevelUpDialog(
          levelName: evt.toLevelName,
          imagePath: imagePath,
          onOk: () => Navigator.of(context).pop(),
        );
      },
    );

    _levelUpDialogOpen = false;
  }

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    final emailText = _email ?? "Email non presente";

    return Scaffold(
      backgroundColor: AppTheme.creamColor,
      floatingActionButton: _loading || _error != null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'fab_xp',
                  onPressed: () => giveXp(
                    service: _service,
                    email: _email,
                    xp: 50,
                    context: context,
                  ),
                  tooltip: 'Aggiungi XP',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.upgrade),
                ),
                const SizedBox(height: 12),

                FloatingActionButton(
                  heroTag: 'fab_flamingo_plus',
                  onPressed: () => giveFlamingo(
                    service: _service,
                    email: _email,
                    qty: 50,
                    context: context,
                  ),
                  tooltip: 'Aggiungi fenicottero',
                  backgroundColor: Colors.pinkAccent,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(fontSize: 16)))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Header con sfondo scelto
                            SizedBox(
                              height: 220,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    _bgAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      ShopPrefs.defaultBackground,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: -80,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    height: 120,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Anello di progresso animato
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: _levelProgress(_user),
                                          ),
                                          duration: const Duration(milliseconds: 700),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, value, _) {
                                            return SizedBox(
                                              width: 110,
                                              height: 110,
                                              child: CircularProgressIndicator(
                                                value: value,
                                                strokeWidth: 8,
                                                backgroundColor: Colors.white.withOpacity(0.35),
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        // Avatar selezionato
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
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: ClipOval(
                                            child: Image.asset(
                                              _avatarAsset,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Image.asset(
                                                ShopPrefs.defaultAvatar,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // XP mancanti (etichetta)
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _user?.nextLevel == null ? 'MAX' : '${_xpToNext(_user)} XP',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(emailText, style: const TextStyle(fontSize: 16)),
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
                            children: [
                              InfoCard(
                                title: 'Livello',
                                subtitle: _user?.currentLevel.name ?? '-',
                                assetImagePath: _user?.currentLevel.imageUrl ?? 'assets/icons/binoculars.png',
                                description:
                                    "Il livello indica quanto sei esperto e familiare con il parco in questo momento. Più esplori e ti metti in gioco, più crescerà!",
                              ),
                              InfoCard(
                                title: 'Prossimo Livello',
                                subtitle: _user?.nextLevel?.name ?? '—',
                                assetImagePath: _user?.nextLevel?.imageUrl ?? 'assets/icons/research.png',
                                description:
                                    "Il prossimo livello è il traguardo che ti aspetta: continua ad accumulare punti esperienza per raggiungerlo.",
                              ),
                              InfoCard(
                                title: 'Fenicotteri',
                                subtitle: (_user?.amount.amount ?? 0).toString(),
                                assetImagePath: 'assets/icons/flamingo.png',
                                description:
                                    "I fenicotteri sono la tua moneta speciale: ottienili esplorando e completando missioni.",
                              ),
                              InfoCard(
                                title: 'Punti Esperienza',
                                subtitle: (_user?.xpReached ?? 0).toString(),
                                assetImagePath: 'assets/icons/upgrade.png',
                                description:
                                    "I punti esperienza ti aiutano a crescere di livello: più esplori, più XP ottieni.",
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
