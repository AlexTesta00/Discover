import 'dart:async';
import 'dart:io';
import 'package:discover/features/maps/presentation/pages/itinerary_page.dart';
import 'package:discover/features/challenge/domain/entities/challenge.dart';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/challenge/domain/use_cases/photo_capture_service.dart';
import 'package:discover/features/challenge/domain/use_cases/photo_label_service.dart';
import 'package:discover/features/challenge/presentation/widgets/modal_not_completed.dart';
import 'package:discover/features/challenge/utils/utils.dart';
import 'package:discover/features/maps/presentation/widgets/photo_challenge_picker_dialog.dart';
import 'package:discover/features/maps/presentation/controller/tracking_controller.dart';
import 'package:discover/features/maps/presentation/pages/ar_character_page.dart';
import 'package:discover/features/maps/presentation/widgets/banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/point_of_interest.dart';
import '../../domain/use_cases/map_service.dart';
import '../../domain/use_cases/parks/geo_json_loader.dart';
import '../../domain/use_cases/osrm_routing_provider.dart';
import '../../domain/use_cases/routing_provider.dart';
import '../widgets/map_view.dart';
import '../widgets/off_screen_indicators.dart';
import '../widgets/poi_bottom_sheet.dart';
import '../widgets/poi_arrival_sheet.dart';
import 'package:discover/utils/presentation/pages/loading_page.dart';
import 'package:discover/features/character/domain/entities/character.dart';
import 'package:discover/features/character/domain/use_cases/character_service.dart';
import 'package:discover/features/character/presentation/pages/character_detail_page.dart';

class MapGate extends StatefulWidget {
  const MapGate({super.key});
  @override
  State<MapGate> createState() => _MapGateState();
}

class _MapGateState extends State<MapGate> {
  static const LatLng _riccioneCenter = LatLng(43.9992, 12.6563);

  StreamSubscription? _busSub;
  // ignore: unused_field
  String? _highlightPoiId;

  // Map & services
  final MapController _mapController = MapController();
  final MapService _mapUtils = MapService();
  final RoutingProvider _routing = OSRMRoutingProvider();

  late final TrackingController _ctrl = TrackingController(mapController: _mapController, mapService: _mapUtils, routingProvider: _routing)
    ..onArrived = _showArrivalModal;

  // POI & characters
  List<PredefinedPoi> _pois = [];
  Map<String, Character> _charactersById = {};
  bool _loadingPois = true;
  String? _poisError;

  Set<String> _completedTalkCharacterIds = {};

  final bool _parkVisible = true;

  @override
  void initState() {
    super.initState();
    _loadPois();
    _ctrl.startLocation();
    _loadParks();
    _loadCompletedTalkChallenges();

    _busSub = ChallengeEventBus.I.stream.listen((e) {
      if (e is GoToMapForCharacterEvent) {
        _focusPoiByCharacterId(e.characterId);
      }
    });
  }

  @override
  void dispose() {
    _busSub?.cancel();
    _ctrl.disposeAll();
    _ctrl.dispose();
    super.dispose();
  }

  void _focusPoiByCharacterId(String characterId) {
    if (_pois.isEmpty) return;

    final poi = _pois.where((p) => p.id == characterId).cast<PredefinedPoi?>().firstOrNull;
    if (poi == null) return;

    setState(() => _highlightPoiId = poi.id);

    _mapController.move(poi.position, 16);

    _onPoiTap(poi);
  }

  Future<void> _loadParks() async {
    final polys = await loadGeoJsonPolygons('assets/geo/delta_po.geojson');
    if (mounted) _mapUtils.setPolygons(polys);
  }

  Future<void> _loadPois() async {
    try {
      final characters = await CharactersApi().getAllCharacters();
      _charactersById = {for (final c in characters) c.id: c};
      setState(() {
        _pois = characters.map((c) => c.toPoi()).toList();
        _loadingPois = false;
      });
    } catch (e) {
      setState(() {
        _poisError = e.toString();
        _loadingPois = false;
      });
      _showSnack('Errore caricamento personaggi: $e');
      return;
    }
  }

  Future<void> _loadCompletedTalkChallenges() async {
    try {
      final repo = ChallengeRepository(Supabase.instance.client);
      final completedIds = await repo.fetchCompletedIds();
      final allChallenges = await repo.fetchAllWithCharacter();
      final ids = allChallenges
          .where((c) => !c.requiresPhoto && completedIds.contains(c.id))
          .map((c) => c.characterId)
          .toSet();
      if (mounted) setState(() => _completedTalkCharacterIds = ids);
    } catch (e) {
      debugPrint('Errore caricamento talk challenges completate: $e');
    }
  }

  // TAP marker:
  // - entro 20 m → dialog di ARRIVO
  // - altrimenti → bottom sheet "Raggiungi"
  void _onPoiTap(PredefinedPoi poi) {
    _ctrl.selectPoi(poi);

    if (_ctrl.isNearPoi(poi)) {
      _showArrivalModal(poi);
      return;
    }

    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => PoiBottomSheet(
        poi: poi,
        onStart: () {
          Navigator.of(ctx).pop();
          _ctrl.startLiveToSelectedPoi();
        },
      ),
    );
  }

  // Modal di ARRIVO:
  // - completa la challenge "Parla con X"
  // - mostra sheet con:
  //   - Leggi la storia
  //   - Vedi in AR (camera + PNG del personaggio)
  void _showArrivalModal(PredefinedPoi poi) async {
    if (!_completedTalkCharacterIds.contains(poi.id)) {
      final bus = ChallengeEventBus.I;
      final repo = ChallengeRepository(Supabase.instance.client);

      try {
        final (submissionId, wasNew) = await repo.completeTalkChallengeForCharacter(poi.id);
        _completedTalkCharacterIds.add(poi.id);

        if (submissionId != null && wasNew) {
          final allChallenges = await repo.fetchAllWithCharacter();
          final challenge = allChallenges.firstWhere((c) => c.characterId == poi.id && c.requiresPhoto == false);
          bus.publish(ChallengeCompletedEvent(submissionId: submissionId, challenge: challenge));
        }
      } catch (e) {
        debugPrint('Errore completamento challenge RPC: $e');
      }
    }

    //Mostra il modale di arrivo
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => PoiArrivalSheet(
        poi: poi,
        onReadStory: () {
          Navigator.of(ctx).pop();
          final character = _charactersById[poi.id];
          if (character != null) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => CharacterDetailPage(character: character)));
          } else {
            _showSnack('Dati del personaggio non disponibili.');
          }
        },
        onViewAr: () {
          Navigator.of(ctx).pop();
          final character = _charactersById[poi.id];
          if (character != null) {
            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => ARCharacterPage(character: character)));
          } else {
            _showSnack('Dati del personaggio non disponibili.');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final showBanner = _ctrl.isTracking && (_ctrl.remainMeters > 0 || _ctrl.etaSeconds > 0);

        return Scaffold(
          body: Stack(
            children: [
              MapView(
                mapController: _mapController,
                mapUtils: _mapUtils,
                initialCenter: _riccioneCenter,
                userLatLng: _ctrl.userLatLng,
                pois: _pois,
                onPoiTap: _onPoiTap,
                showParkArea: _parkVisible,
              ),
              if (_pois.isNotEmpty)
                OffScreenPoiIndicators(mapController: _mapController, pois: _pois, userLatLng: _ctrl.userLatLng, onTap: _onPoiTap),
              EtaBanner(visible: showBanner, remainMeters: _ctrl.remainMeters, etaSeconds: _ctrl.etaSeconds, onStop: _ctrl.stopTracking),
              // Controlli mappa + FAB fotocamera — in basso a destra
              Positioned(
                right: 16,
                bottom: 0,
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'center_user',
                        onPressed: _ctrl.centerOnUser,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton.small(
                        heroTag: 'reset_north',
                        onPressed: _ctrl.resetRotationNorth,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 4,
                        child: const Icon(Icons.explore),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: 'take_photo',
                        onPressed: _openPhotoChallengeDialog,
                        backgroundColor: const Color(0xFFF34E6C),
                        foregroundColor: Colors.white,
                        elevation: 6,
                        child: const Icon(Icons.photo_camera),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 0,
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 24),
                  child: FloatingActionButton.small(
                    heroTag: 'itineraries',
                    onPressed: _openItineraryPage,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    child: const Icon(Icons.route),
                  ),
                ),
              ),
              if (_loadingPois) const Positioned(top: 60, left: 0, right: 0, child: LoadingPage()),
              if (_poisError != null)
                Positioned(
                  top: 60,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text('Errore: $_poisError', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openPhotoChallengeDialog() async {
    if (_charactersById.isEmpty) {
      _showSnack('Nessun personaggio disponibile.');
      return;
    }

    final characters = _charactersById.values.toList()..sort((a, b) => a.name.compareTo(b.name));

    final selected = await showDialog<Character>(
      context: context,
      builder: (_) => PhotoChallengePickerDialog(characters: characters),
    );

    if (selected == null || !mounted) return;

    List<Challenge> photoChallenges;
    try {
      final repo = ChallengeRepository(Supabase.instance.client);
      final all = await repo.fetchAllWithCharacter();
      photoChallenges = all.where((c) => c.requiresPhoto).toList();
    } catch (e) {
      if (mounted) _showSnack('Errore caricamento sfide: $e');
      return;
    }

    if (!mounted) return;

    final matches = photoChallenges.where((c) => c.characterId == selected.id);
    if (matches.isEmpty) {
      _showSnack('Nessuna sfida fotografica per ${selected.name}.');
      return;
    }

    final challenge = matches.first;
    final repo = ChallengeRepository(Supabase.instance.client);

    File? file;
    try {
      file = await PhotoCaptureService(repo).captureOnly();
    } catch (e) {
      if (mounted) _showSnack('Errore fotocamera: $e');
      return;
    }

    if (file == null) return; // annullato
    if (!mounted) return;

    // Validazione ML con context locale (evita il problema di navKey.currentContext null)
    final labelService = PhotoLabelService(confidence: 0.6);
    final mlLabels = await labelService.labelsFor(file);
    final ok = anyLabelMatches(mlLabels: mlLabels, challengeLabels: challenge.labels);

    if (!ok) {
      if (mounted) await showNotCompletedModal(context, challenge: challenge);
      return;
    }

    if (!mounted) return;

    try {
      final completedIds = await repo.fetchCompletedIds();
      final isFirst = !completedIds.contains(challenge.id);

      final submissionId = await repo.insertChallengeSubmission(
        challengeId: challenge.id,
        photoFile: file,
        photoMeta: {'ml_labels': mlLabels.toList(), 'challenge_labels': challenge.labels},
      );

      ChallengeEventBus.I.publish(
        ChallengeCompletedEvent(
          submissionId: submissionId,
          challenge: challenge,
          isFirstCompletion: isFirst,
        ),
      );
    } catch (e) {
      if (mounted) _showSnack('Errore salvataggio: $e');
    }
  }

  void _openItineraryPage() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const ItineraryPage()),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
