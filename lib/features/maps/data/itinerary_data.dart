import 'package:discover/features/maps/domain/entities/itinerary.dart';
import 'package:flutter/material.dart';

final List<ItineraryGroup> itineraryGroups = [
  ItineraryGroup(
    category: ItineraryCategory.stazioni,
    label: 'Itinerari per Stazioni',
    color: const Color(0xFFF5A623),
    icon: Icons.train,
    assetPaths: [
      'assets/geo/itinerari/stazioni/calle-baiona.geojson',
      'assets/geo/itinerari/stazioni/campotto-argenta.geojson',
      'assets/geo/itinerari/stazioni/volano-mesola-goro.geojson',
      'assets/geo/itinerari/stazioni/pineta-classe-saline.geojson',
      'assets/geo/itinerari/stazioni/punte-alberete.geojson',
      'assets/geo/itinerari/stazioni/trepponti.geojson',
    ],
  ),
  ItineraryGroup(
    category: ItineraryCategory.parcoPerTutti,
    label: 'Un Parco per Tutti',
    color: const Color(0xFF4CAF50),
    icon: Icons.accessibility_new,
    assetPaths: [
      'assets/geo/itinerari/tutti/anello-dolce-salato.geojson',
      'assets/geo/itinerari/tutti/pedalando-immersi-nella-pineta.geojson',
      'assets/geo/itinerari/tutti/pedalando-tra-la-storia.geojson',
      'assets/geo/itinerari/tutti/pedalando-tra-porto-e-salina.geojson',
    ],
  ),
  ItineraryGroup(
    category: ItineraryCategory.bici,
    label: 'Itinerari in Bici',
    color: const Color(0xFF2196F3),
    icon: Icons.directions_bike,
    assetPaths: [
      'assets/geo/itinerari/bici/ciclovia-valli-argine.geojson',
      'assets/geo/itinerari/bici/da-valle-a-valle.geojson',
      'assets/geo/itinerari/bici/lamone.geojson',
      'assets/geo/itinerari/bici/pinete.geojson',
      'assets/geo/itinerari/bici/ravenna-cervia.geojson',
      'assets/geo/itinerari/bici/sterrati-savio.geojson',
    ],
  ),
  ItineraryGroup(
    category: ItineraryCategory.birdwatching,
    label: 'Birdwatching',
    color: const Color(0xFF009688),
    icon: Icons.cruelty_free,
    assetPaths: [],
  ),
];
