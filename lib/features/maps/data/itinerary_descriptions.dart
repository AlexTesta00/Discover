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
      title: 'Tutti i colori del verde',
      body:
          'Parcheggiando nell’area attigua a Vallesanta (dove è attivo un servizio di noleggio bici) il giovedì nei giorni festivi e prefestivi, è possibile compiere in bici tutto l’intero perimetro della valle (circa 9 km) ammirando intorno il caratteristico prato umido. Durante la settimana il circuito percorribile si articola invece su un tratto di 5 chilometri.',
    ),
    ItinerarySection(
      title: 'Info:',
      body:
          'Museo delle Valli di Argenta tel. + 39 0532 808058\nMuseo della Bonifica tel. + 39 0532 808058\nIAT Argenta - tel. + 39 0532 330276',
    ),
  ],

  'trepponti': [
    ItinerarySection(
      title: 'In cammino sui ponti',
      body:
          'Dal monumentale Ponte Trepponti si arriva al ponte degli Sbirri e costeggiando il canale di Via Agatopisto si incontra il ponte di San Pietro; passando sull’altra riva e attraversando un piccolo ponte in cotto (Ponte dei Sisti) - girando subito a sinistra - si segue poi il corso del canale di via Buonafede, arrivando nella parte retrostante del Museo Delta Antico (il vicolo sulla destra riporta su via Agatopisto). Si prosegue per via E. Fogli, seguendo il corso delle acque, si passa accanto al ponte di Via Cavour. Attraversando altri due ponti su via Carducci e l’omonimo in Rione Carmine: si percorre via del Rosario e di seguito via Muratori. Si è di nuovo al Ponte Trepponti.',
    ),
    ItinerarySection(
      title: 'La "storia" della tradizione',
      body:
          'Dal Santuario di S.M. in Aula Regia, dopo la visita alla Manifattura dei Marinati (centro visita del Parco) percorrendo il porticato dei Cappuccini si arriva al centro della città: ecco la Cattedrale di San Cassiano e l’imponente torre campanaria. Proseguendo verso P.tta U. Bassi e portandosi - a sinistra - in via Cavour, si accede al Sacrario dei Caduti; costeggiando il canale - in fondo a destra - si arriva al rione Carmine, dove si può ammirare l’omonima chiesa dedicata alla Madonna. Salendo sul ponte antistante (Ponte del Carmine) è chiaramente visibile uno scorcio della chiesa del Rosario. Percorrendo P.zza Folegatti prima, e via E. Fogli poi, si raggiunge la piccola chiesa di San Pietro annessa all’ex Ospedale settecentesco San Camillo ora sede del Museo Delta Antico.',
    ),
    ItinerarySection(
      title: "Un Museo Sull'Acqua",
      body:
          'Il Museo Delta Antico è un museo archeologico di Comacchio, allestito nell’ospedale degli Infermi. Conserva una collezione di circa 2000 reperti di epoca protostorica, spinetica (la città di Spina, a pochi chilometri da Comacchio, era un porto etrusco che commerciava con la Grecia (nella sua necropoli sono state trovate più di 4.000 tombe, alle quali vanno aggiunti gli scavi di una parte dell’abitato), romana e medievale; vi è esposto anche il carico della Fortuna Maris, una nave commerciale di epoca imperiale riemersa nel 1981. Il museo si compone diverse sezioni dedicate a reperti delle culture che vissero nella zona del delta del Po oltre ad una sezione di tema geologico-ambientale che illustra i cambiamenti del territorio nel corso dei millenni, dalla formazione della pianura padana ai giorni nostri.',
    ),
    ItinerarySection(
      title: 'Info:',
      body:
          'Centro visite Manifattura dei Marinati Tel. 39 0533 81742\nIAT Comacchio tel. + 39 0533 314154\nMuseo Delta Antico tel. + 39 0533 311316',
    ),
  ],

  'pineta-classe': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'saline': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'pineta-cervia': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'punte-alberete': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'calle-baiona': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'mesola-fasanara': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  'gorino': [ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...')],

  // ── Un Parco per Tutti ────────────────────────────────────────────────────
  'pedalando-immersi-nella-pineta': [
    ItinerarySection(title: 'Titolo sezione', body: 'Testo della sezione...'),
  ],

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
