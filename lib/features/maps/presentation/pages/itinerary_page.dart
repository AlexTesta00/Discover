import 'package:discover/features/maps/data/sources/point_of_interest_remote_data_source.dart';
import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:discover/features/maps/domain/use_cases/build_itinerary.dart';
import 'package:discover/features/maps/presentation/widgets/point_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({super.key});

  @override
  State<ItineraryPage> createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  final _mapController = MapController();
  List<PointOfInterest> _markers = const [];
  List<PointOfInterest> _availablePoints = const [];
  List<PointOfInterest> _selectedPoints = const [];

  @override
  void initState() {
    super.initState();
    loadPointsFromJson().run().then((result) {
      result.match(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        ),
        (points) {
          setState(() {
            _availablePoints = points;
          });
        },
      );
    });
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers = addPointOfInterest(_markers, position);
    });
  }

  Future<void> _openGoogleMaps() async {
    final result = buildItineraryUrl(_markers.map((m) => m.position).toList());

    result.match(
      (error) => {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        )
      },
      (url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Impossibile aprire Google Maps")),
          );
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      44.014144673845216,
                      12.637168847679812
                    ),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    ),
                    MarkerLayer(
                      markers: _markers.map((p) => Marker(
                          point: p.position,
                          width: 40.0,
                          height: 40.0, 
                          child: const Icon(Icons.location_on, color: Colors.red, size: 40.0)
                        ),
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: const Text(
                    "Punti di Interesse",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: _availablePoints.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availablePoints.length,
                          itemBuilder: (context, index) {
                            final point = _availablePoints[index];
                            final isSelected = _selectedPoints.contains(point);
                            return PointCard(
                              point: point,
                              selected: isSelected,
                              onSelected: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedPoints = List.unmodifiable([..._selectedPoints, point]);
                                    _markers = addPointOfInterest(_markers, point.position);
                                  } else {
                                    _selectedPoints = List.unmodifiable(_selectedPoints.where((p) => p != point));
                                    _markers = List.unmodifiable(_markers.where((p) => p.position != point.position));
                                  }
                                });
                                _mapController.move(point.position, _mapController.camera.zoom);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _openGoogleMaps,
                icon: const Icon(Icons.directions),
                label: const Text("Inizia Itinerario"),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}