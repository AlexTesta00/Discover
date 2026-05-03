class ItinerarySection {
  const ItinerarySection({this.title, required this.body});
  final String? title;
  final String body;
}

/// Mappa: stem del filename → lista di sezioni della descrizione.
/// Ogni sezione può avere un titolo opzionale (reso in grassetto) e un testo.
const Map<String, List<ItinerarySection>> itineraryDescriptions = {
  // ── Itinerari per Stazioni ────────────────────────────────────────────────
  'campotto-argenta': [
    ItinerarySection(
      title: 'Pennellate di storia e natura',
      body:
          "Dal centro di Argenta, dopo aver effettuato una visita al Museo Civico, si prosegue per un chilometro fino alla pregevole Pieve di San Giorgio. Tuttavia, per comprendere la trasformazione del territorio, non può mancare una visita al Museo della Bonifica, posto più a nord. Scendendo in direzione sud è possibile fare osservazioni naturalistiche nel capanno da birdwatching situato sull'argine di Cassa Campotto. Proseguendo si raggiunge il Museo delle Valli di Argenta.",
    ),
    ItinerarySection(
      title: 'Acqua, cielo e bici',
      body:
          'Dall’antica Pieve di S. Giorgio fino al Casino di Campotto e al Museo delle Valli di Argenta, l’itinerario suggerito, da percorrere in bicicletta, si sviluppa sull’argine che costeggia la Cassa Bassarone e la Cassa di espansione di Campotto: un tracciato di circa 6 chilometri che consente di spaziare sull’intera superficie valliva disseminata di ninfee, canneti e tifeti. Dal Museo delle Valli prende avvio un percorso, di circa 10 chilometri, che permette di ammirare il paesaggio accompagnati da guida.',
    ),
    ItinerarySection(
      title: "Tutti i colori del verde",
      body:
          'Parcheggiando nell’area attigua a Vallesanta (dove è attivo un servizio di noleggio bici) il giovedì nei giorni festivi e prefestivi, è possibile compiere in bici tutto l’intero perimetro della valle (circa 9 km) ammirando intorno il caratteristico prato umido. Durante la settimana il circuito percorribile si articola invece su un tratto di 5 chilometri.',
    ),
  ],

  'trepponti': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'pineta-classe': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'saline': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'pineta-cervia': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'punte-alberete': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'calle-baiona': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'mesola-fasanara': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'gorino': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  // ── Un Parco per Tutti ────────────────────────────────────────────────────
  'pedalando-immersi-nella-pineta': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'pedalando-tra-la-storia': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'pedalando-tra-porto-e-salina': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  // ── Itinerari in Bici ─────────────────────────────────────────────────────
  'ciclovia-valli-argine': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'da-valle-a-valle': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'lamone': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'pinete': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'ravenna-cervia': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'sterrati-savio': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],
};
