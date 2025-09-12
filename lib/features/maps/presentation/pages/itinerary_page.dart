import 'package:discover/features/maps/data/sources/geolocator_location_tracker.dart';
import 'package:discover/features/maps/data/sources/json_points_repository.dart';
import 'package:discover/features/maps/data/sources/openroute_service_adapter.dart';
import 'package:discover/features/maps/data/sources/rewards_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:discover/features/maps/presentation/pages/transport_model_dialog.dart';
import 'package:discover/features/challenge/presentation/widgets/modal_card.dart';
import '../controller/itinerary_controller.dart';
import '../controller/itinerary_state.dart';
import '../widgets/itinerary_map.dart';
import '../widgets/points_horizontal_list.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final _mapController = MapController();
  late final ItineraryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ItineraryController(
      pointsRepo: JsonPointsRepository(),
      routeService: OpenRouteServiceAdapter(),
      locationTracker: GeolocatorLocationTracker(),
      rewardsService: RewardsAdapter(),
      onMessage: (msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg))),
      onRewardDialog: ({required xp, required flamingo}) async => showDialog(
        context: context,
        builder: (_) => ModalCard(xp: xp, flamingo: flamingo),
      ),
    );
    _controller.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final ItineraryState s = _controller.state;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ItineraryMap(
                  mapController: _mapController,
                  routePoints: s.routePoints,
                  markers: s.markers.map((m) => m.position).toList(growable: false),
                  userLocation: s.userPose?.position,
                  isExpanded: s.isMapExpanded,
                  onToggleExpand: _controller.toggleMapExpanded,
                ),
                const SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text('Punti di Interesse', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    SizedBox(
                      height: 200,
                      child: PointsHorizontalList(
                        points: s.availablePoints,
                        selected: s.selectedPoints,
                        absorb: s.isItineraryActive,
                        onToggle: (point, checked) {
                          if (checked) {
                            _controller.selectPoint(point);
                          } else {
                            _controller.deselectPoint(point);
                          }
                          _mapController.move(point.position, _mapController.camera.zoom);
                        },
                        onFocus: (point) => _mapController.move(point.position, _mapController.camera.zoom),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (s.isItineraryActive) {
                        _controller.finishItinerary();
                      } else {
                        // choose transport mode then start
                        showDialog(
                          context: context,
                          builder: (_) => TransportModeDialog(
                            onWalkingSelected: () => _controller.startItinerary('foot-walking'),
                            onCyclingSelected: () => _controller.startItinerary('cycling-regular'),
                          ),
                        );
                      }
                    },
                    icon: Icon(s.isItineraryActive ? Icons.stop : Icons.directions),
                    label: Text(s.isItineraryActive ? 'Finisci Itinerario' : 'Inizia Itinerario'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}