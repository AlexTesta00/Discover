class ItineraryAnimal {
  const ItineraryAnimal({required this.name, this.category, this.imageAsset});
  final String name;
  final String? category;
  final String? imageAsset;
}

/// Mappa: stem del filename → lista di animali osservabili.
const Map<String, List<ItineraryAnimal>> itineraryFauna = {
  // ── Itinerari per Stazioni ────────────────────────────────────────────────

  'campotto-argenta': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
  ],

  'trepponti': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
  ],

  'pineta-classe-saline': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
    ItineraryAnimal(name: 'Cervo', category: 'Mammiferi', imageAsset: 'assets/characters/cervo.webp'),
    ItineraryAnimal(name: 'Daino', category: 'Mammiferi', imageAsset: 'assets/characters/daino.webp'),
    ItineraryAnimal(name: 'Scoiattolo', category: 'Mammiferi', imageAsset: 'assets/characters/scoiattolo.webp'),
    ItineraryAnimal(name: 'Cinghiale', category: 'Mammiferi', imageAsset: 'assets/characters/cinghiale.webp'),
  ],

  'punte-alberete': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
    ItineraryAnimal(name: 'Cervo', category: 'Mammiferi', imageAsset: 'assets/characters/cervo.webp'),
    ItineraryAnimal(name: 'Daino', category: 'Mammiferi', imageAsset: 'assets/characters/daino.webp'),
    ItineraryAnimal(name: 'Scoiattolo', category: 'Mammiferi', imageAsset: 'assets/characters/scoiattolo.webp'),
    ItineraryAnimal(name: 'Cinghiale', category: 'Mammiferi', imageAsset: 'assets/characters/cinghiale.webp'),
  ],

  'calle-baiona': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
  ],

  'volano-mesola-goro': [
    ItineraryAnimal(name: 'Cervo', category: 'Mammiferi', imageAsset: 'assets/characters/cervo.webp'),
    ItineraryAnimal(name: 'Daino', category: 'Mammiferi', imageAsset: 'assets/characters/daino.webp'),
    ItineraryAnimal(name: 'Cinghiale', category: 'Mammiferi', imageAsset: 'assets/characters/cinghiale.webp'),
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
  ],

  // ── Un Parco per Tutti ────────────────────────────────────────────────────

  'anello-dolce-salato': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
    ItineraryAnimal(name: 'Scoiattolo', category: 'Mammiferi', imageAsset: 'assets/characters/scoiattolo.webp'),
  ],

  'pedalando-immersi-nella-pineta': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
    ItineraryAnimal(name: 'Scoiattolo', category: 'Mammiferi', imageAsset: 'assets/characters/scoiattolo.webp'),
    ItineraryAnimal(name: 'Cinghiale', category: 'Mammiferi', imageAsset: 'assets/characters/cinghiale.webp'),
  ],

  'pedalando-tra-la-storia': [
    ItineraryAnimal(name: 'Cervo', category: 'Mammiferi', imageAsset: 'assets/characters/cervo.webp'),
    ItineraryAnimal(name: 'Daino', category: 'Mammiferi', imageAsset: 'assets/characters/daino.webp'),
    ItineraryAnimal(name: 'Cinghiale', category: 'Mammiferi', imageAsset: 'assets/characters/cinghiale.webp'),
    ItineraryAnimal(name: 'Tasso', category: 'Mammiferi', imageAsset: 'assets/characters/tasso.webp'),
  ],

  'pedalando-tra-porto-e-salina': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
    ItineraryAnimal(name: 'Cervo', category: 'Mammiferi', imageAsset: 'assets/characters/cervo.webp'),
    ItineraryAnimal(name: 'Daino', category: 'Mammiferi', imageAsset: 'assets/characters/daino.webp'),
  ],

  // ── Itinerari in Bici ─────────────────────────────────────────────────────

  'ciclovia-valli-argine': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
  ],

  'da-valle-a-valle': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
  ],

  'lamone': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
  ],

  'pinete': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
    ItineraryAnimal(name: 'Scoiattolo', category: 'Mammiferi', imageAsset: 'assets/characters/scoiattolo.webp'),
    ItineraryAnimal(name: 'Cinghiale', category: 'Mammiferi', imageAsset: 'assets/characters/cinghiale.webp'),
  ],

  'ravenna-cervia': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Scoiattolo', category: 'Mammiferi', imageAsset: 'assets/characters/scoiattolo.webp'),
    ItineraryAnimal(name: 'Cervo', category: 'Mammiferi', imageAsset: 'assets/characters/cervo.webp'),
    ItineraryAnimal(name: 'Daino', category: 'Mammiferi', imageAsset: 'assets/characters/daino.webp'),
  ],

  'sterrati-savio': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
  ],

  // ── Birdwatching ─────────────────────────────────────────────────────────

  'birdwatching-campotto-argenta': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
  ],

  'birdwatching-saline': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
  ],

  'birdwatching-baiona': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
    ItineraryAnimal(name: 'Scoiattolo', category: 'Mammiferi', imageAsset: 'assets/characters/scoiattolo.webp'),
  ],

  'birdwatching-valli-comacchio': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Fratino', category: 'Uccelli', imageAsset: 'assets/characters/fratino.webp'),
    ItineraryAnimal(name: 'Aquila', category: 'Uccelli', imageAsset: 'assets/characters/acquila.webp'),
    ItineraryAnimal(name: 'Anguilla', category: 'Pesci', imageAsset: 'assets/characters/anguilla.webp'),
  ],

  'birdwatching-volano-mesola-goro': [
    ItineraryAnimal(name: 'Fenicottero', category: 'Uccelli', imageAsset: 'assets/characters/fenicottero.webp'),
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Cervo', category: 'Mammiferi', imageAsset: 'assets/characters/cervo.webp'),
    ItineraryAnimal(name: 'Daino', category: 'Mammiferi', imageAsset: 'assets/characters/daino.webp'),
  ],

  'birdwatching-vallette-di-ostellato': [
    ItineraryAnimal(name: 'Airone', category: 'Uccelli', imageAsset: 'assets/characters/airone.webp'),
    ItineraryAnimal(name: 'Martin Pescatore', category: 'Uccelli', imageAsset: 'assets/characters/martin.webp'),
  ],
};
