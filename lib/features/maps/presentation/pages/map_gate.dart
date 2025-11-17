import 'dart:async';
import 'package:discover/features/challenge/domain/entities/event.dart';
import 'package:discover/features/challenge/domain/repository/challenge_repository.dart';
import 'package:discover/features/maps/presentation/controller/tracking_controller.dart';
import 'package:discover/features/maps/presentation/pages/ar_character_page.dart';
import 'package:discover/features/maps/presentation/widgets/banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/point_of_interest.dart';
import '../../domain/use_cases/map_service.dart';
import '../../domain/use_cases/osrm_routing_provider.dart';
import '../../domain/use_cases/routing_provider.dart';
import '../widgets/map_view.dart';
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

  // Map & services
  final MapController _mapController = MapController();
  final MapService _mapUtils = MapService();
  final RoutingProvider _routing = OSRMRoutingProvider();

  late final TrackingController _ctrl = TrackingController(
    mapController: _mapController,
    mapService: _mapUtils,
    routingProvider: _routing,
  )..onArrived = _showArrivalModal;

  // POI & characters
  List<PredefinedPoi> _pois = [];
  Map<String, Character> _charactersById = {};
  bool _loadingPois = true;
  String? _poisError;

  @override
  void initState() {
    super.initState();
    _loadPois();
    _ctrl.startLocation();
  }

  @override
  void dispose() {
    _ctrl.disposeAll();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadPois() async {
    try {
      final characters = await CharactersApi().getAllCharacters();
      _charactersById = {for (final c in characters) c.id: c};

      setState(() {
        _pois = characters
            .map(
              (c) => PredefinedPoi(
                id: c.id,
                name: c.name,
                position: LatLng(c.lat, c.lng),
                imageAsset: c.imageAsset,
              ),
            )
            .toList();
        _loadingPois = false;
      });
    } catch (e) {
      setState(() {
        _poisError = e.toString();
        _loadingPois = false;
      });
      _showSnack('Errore caricamento personaggi: $e');
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
    final bus = ChallengeEventBus.I;
    final client = Supabase.instance.client;
    final repo = ChallengeRepository(client);

    // 1️⃣ Completa la challenge "Parla con X" via RPC
    try {
      final (submissionId, wasNew) =
          await repo.completeTalkChallengeForCharacter(poi.id);

      // 2️⃣ Se è la prima volta → emetti l'evento ChallengeCompletedEvent
      if (submissionId != null && wasNew) {
        final allChallenges = await repo.fetchAllWithCharacter();
        final challenge = allChallenges.firstWhere(
          (c) => c.characterId == poi.id && c.requiresPhoto == false,
        );

        bus.publish(
          ChallengeCompletedEvent(
            submissionId: submissionId,
            challenge: challenge,
          ),
        );
      }
    } catch (e) {
      debugPrint('Errore completamento challenge RPC: $e');
    }

    // 3️⃣ Mostra il modale di arrivo
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PoiArrivalSheet(
        poi: poi,
        onReadStory: () {
          Navigator.of(ctx).pop();
          final character = _charactersById[poi.id];
          if (character != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CharacterDetailPage(character: character),
              ),
            );
          } else {
            _showSnack('Dati del personaggio non disponibili.');
          }
        },
        onViewAr: () {
          Navigator.of(ctx).pop();
          final character = _charactersById[poi.id];
          if (character != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ARCharacterPage(character: character),
              ),
            );
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
        final showBanner =
            _ctrl.isTracking && (_ctrl.remainMeters > 0 || _ctrl.etaSeconds > 0);

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
              ),
              EtaBanner(
                visible: showBanner,
                remainMeters: _ctrl.remainMeters,
                etaSeconds: _ctrl.etaSeconds,
                onStop: _ctrl.stopTracking,
              ),
              if (_loadingPois)
                const Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: LoadingPage(),
                ),
              if (_poisError != null)
                Positioned(
                  top: 60,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        'Errore: $_poisError',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
