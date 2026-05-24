class ItineraryAnimal {
  const ItineraryAnimal({required this.name, this.category});
  final String name;
  final String? category; // es. "Uccelli", "Mammiferi", "Rettili"
}

/// Mappa: stem del filename → lista di animali osservabili.
const Map<String, List<ItineraryAnimal>> itineraryFauna = {
  // ── Itinerari per Stazioni ────────────────────────────────────────────────
  'campotto-argenta': [],
  'trepponti': [],
  'pineta-classe-saline': [],
  'punte-alberete': [],
  'calle-baiona': [],
  'volano-mesola-goro': [],

  // ── Un Parco per Tutti ────────────────────────────────────────────────────
  'anello-dolce-salato': [],
  'pedalando-immersi-nella-pineta': [],
  'pedalando-tra-la-storia': [],
  'pedalando-tra-porto-e-salina': [],

  // ── Itinerari in Bici ─────────────────────────────────────────────────────
  'ciclovia-valli-argine': [],
  'da-valle-a-valle': [],
  'lamone': [],
  'pinete': [],
  'ravenna-cervia': [],
  'sterrati-savio': [],

  // ── Birdwatching ─────────────────────────────────────────────────────────
  'birdwatching-campotto-argenta': [],
  'birdwatching-saline': [],
  'birdwatching-baiona': [],
  'birdwatching-valli-comacchio': [],
  'birdwatching-volano-mesola-goro': [],
  'birdwatching-vallette-di-ostellato': [],
};
