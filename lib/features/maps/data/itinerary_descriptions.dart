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

  'pineta-classe-saline': [
    ItinerarySection(
      title: 'Nel cuore della Pineta',
      body:
          'Si percorre la SS 16 Adriatica. In località Fosso Ghiaia è posto l\'ingresso alla Pineta di Classe dal quale si arriva al Parco 1° Maggio, cuore della Pineta. Qui partono suggestivi percorsi a piedi, in bicicletta o a cavallo. Inoltrandosi in direzione est si raggiungono la pineta costiera e le dune litoranee oppure, procedendo verso sud, si osservano le zone umide dell\'Ortazzo e dell\'Ortazzino dove si ammirano garzette, folaghe, sterne, cavalieri d\'Italia. I percorsi possono essere ugualmente fruibili giungendo da sud (Cervia – Milano Marittima – Lido di Savio – Lido di Classe) o da nord (Lido di Dante) e persino da Ravenna, percorrendo gli argini dei Fiumi Uniti.',
    ),
    ItinerarySection(
      title: 'Storicamente verde',
      body:
          'La secolare Pineta di Cervia offre numerosi percorsi di visita in bicicletta, a piedi o magari di corsa, seguendo il "percorso vita" che si snoda fra i pini: l\'ingresso principale è posto a Milano Marittima. Le "vie della pineta" si insinuano in ogni direzione: verso sud si giunge a Cervia mentre, nel senso opposto – nord – si può raggiungere Lido di Savio. Verso ovest, invece, si trova un luogo ideale per la salute del corpo: le terme. Poco distante: l\'oasi di assoluta tranquillità del Parco naturale di Cervia dove si possono ammirare cervi, daini e anatre di ogni specie.',
    ),
    ItinerarySection(
      title: 'La via del sale',
      body:
          'Le millenarie Saline di Cervia rappresentano, oggi, uno straordinario connubio tra lavoro umano e ambiente. Sono facilmente raggiungibili procedendo sulla SS 16 Adriatica. Le saline sono rigorosamente protette ed ospitano migliaia di uccelli tra cui fenicotteri, avocette e gabbiani corallini. Possono essere ammirate in auto o in bicicletta percorrendo la strada che da Cervia porta verso Forlì. Alcuni tratti esterni del bacino salino sono percorribili a piedi. Per visite all\'interno della Salina è necessario rivolgersi al Corpo Forestale dello Stato (tel. 0544 980193) o al Centro Visita del Parco presso le Saline (tel. + 39 0544 973040)',
    ),
  ],

  'punte-alberete': [
    ItinerarySection(
      title: 'Nel cuore della Pineta',
      body:
          'Si percorre la SS 16 Adriatica. In località Fosso Ghiaia è posto l\'ingresso alla Pineta di Classe dal quale si arriva al Parco 1° Maggio, cuore della Pineta. Qui partono suggestivi percorsi a piedi, in bicicletta o a cavallo. Inoltrandosi in direzione est si raggiungono la pineta costiera e le dune litoranee oppure, procedendo verso sud, si osservano le zone umide dell\'Ortazzo e dell\'Ortazzino dove si ammirano garzette, folaghe, sterne, cavalieri d\'Italia. I percorsi possono essere ugualmente fruibili giungendo da sud (Cervia – Milano Marittima – Lido di Savio – Lido di Classe) o da nord (Lido di Dante) e persino da Ravenna, percorrendo gli argini dei Fiumi Uniti.',
    ),
    ItinerarySection(
      title: 'Storicamente verde',
      body:
          'La secolare Pineta di Cervia offre numerosi percorsi di visita in bicicletta, a piedi o magari di corsa, seguendo il "percorso vita" che si snoda fra i pini: l\'ingresso principale è posto a Milano Marittima. Le "vie della pineta" si insinuano in ogni direzione: verso sud si giunge a Cervia mentre, nel senso opposto – nord – si può raggiungere Lido di Savio. Verso ovest, invece, si trova un luogo ideale per la salute del corpo: le terme. Poco distante: l\'oasi di assoluta tranquillità del Parco naturale di Cervia dove si possono ammirare cervi, daini e anatre di ogni specie.',
    ),
    ItinerarySection(
      title: 'La via del sale',
      body:
          'Le millenarie Saline di Cervia rappresentano, oggi, uno straordinario connubio tra lavoro umano e ambiente. Sono facilmente raggiungibili procedendo sulla SS 16 Adriatica. Le saline sono rigorosamente protette ed ospitano migliaia di uccelli tra cui fenicotteri, avocette e gabbiani corallini. Possono essere ammirate in auto o in bicicletta percorrendo la strada che da Cervia porta verso Forlì. Alcuni tratti esterni del bacino salino sono percorribili a piedi. Per visite all\'interno della Salina è necessario rivolgersi al Corpo Forestale dello Stato (tel. 0544 980193) o al Centro Visita del Parco presso le Saline (tel. + 39 0544 973040).',
    ),
  ],

  'calle-baiona': [
    ItinerarySection(
      title: 'Sulle ali del Cavaliere d\'Italia',
      body:
          'Partendo da Comacchio, in direzione Ostellato, si percorre un tratto della provinciale per svoltare, a destra, sul ponte che conduce verso le aree bonificate; seguendo le indicazioni per Anita (merita una sosta Valle Zavelea) si raggiunge il fascinoso Argine Agosta che costeggia le Valli di Comacchio. Poco prima di arrivare ad Anita si piega a sinistra verso l\'area meridionale delle Valli. Valli di Ostellato. Seguendo la strada provinciale per Ostellato che costeggia il canale navigabile, si raggiungono agevolmente le omonime Vallette: un\'oasi naturalistica di particolare fascino che offre numerose possibilità di visita.',
    ),
    ItinerarySection(
      title: 'I riflessi della valle',
      body:
          'Il circuito nella parte meridionale delle Valli prende avvio poco prima di Anita. Dirigendosi verso la Foce del Reno, a piedi o in bicicletta, è possibile proseguire sull\'argine del fiume Reno: l\'area è un vero paradiso degli uccelli: fenicotteri, aironi, avocette, gabbiani rosei e corallini. Di grande suggestione, il paesaggio offre angoli d\'interesse naturalistico con scorci fra acqua e cielo fra le valli e il fiume.',
    ),
    ItinerarySection(
      title: 'Nel mondo dell\'anguilla',
      body:
          'Nel mondo dell\'anguilla ci si può addentrare a piedi, in bici o a bordo di una barca. Natura, ambiente e storia intrecciate con la tradizione della pesca: è quanto emerge dalla visita ai "Casoni di Valle" - Serilla, Coccalino, Pegoraro - riportati all\'antico impianto originale. All\'inizio del percorso, in Stazione Foce, è attivo un punto informativo da cui hanno inizio i percorsi in barca nelle valli di Comacchio.',
    ),
    ItinerarySection(
      title: 'Info:',
      body:
          'Prenotazioni: 340 2534267\nE-mail: vallidicomacchio@parcodeltapo.it\nIAT Comacchio tel. + 39 0533 314154',
    ),
  ],

  'volano-mesola-goro': [
    ItinerarySection(
      title: 'A spasso col Duca',
      body:
          'Partendo dal centro di Mesola, dopo una visita al Castello, il percorso prosegue verso la seicentesca Torre dell\'Abate e al vicino Bosco della Fasanara. Costeggiando, verso il mare, il Bosco della Mesola, si raggiunge invece la settecentesca Torre Palù. Portandosi poi verso la laguna si arriva al centro di Goro.',
    ),
    ItinerarySection(
      title: 'Il riflesso del verde',
      body:
          'Un percorso in bicicletta che si sviluppa sul ricamo del fiume: partendo da Mesola, percorrendo in direzione sud l\'argine, con il Bosco planiziale della Mesola da un lato e il corso del Po dall\'altro, si giunge a Goro. Arrivando fino alla Foce del Po, in prossimità di Gorino è possibile raggiungere, a piedi o in bicicletta, angoli suggestivi fra lingue di terra che si insinuano nella laguna.',
    ),
    ItinerarySection(
      title: 'Il volo dei fenicotteri',
      body:
          'Percorrendo, per un breve tratto, la strada Giralda retrostante il complesso abbaziale di Pomposa, si raggiunge la strada per Volano. Passando dalle valli Canneviè - Porticino e dal centro di Volano, si apre l\'incantevole paesaggio delle valli Bertuzzi, Cantone e Nuova.\nIn questa area, da diversi anni, da aprile a ottobre, vive una numerosissima colonia di fenicotteri. Attraverso la strada panoramica Acciaioli - direzione sud - si raggiunge l\'accogliente litorale comacchiese.',
    ),
    ItinerarySection(
      title: 'Info:',
      body:
          'Museo del Bosco e del Cervo della Mesola tel. + 39 339 1935943\nIAT Mesola tel. + 39 0533 993358\nIAT Abbazia di Pomposa tel. + 39 0533 719110\nIAT Goro tel. + 39 0533 995030\nTel + 39 3452518596 - E-mail: info@aqua-deltadelpo.com',
    ),
  ],

  // ── Un Parco per Tutti ────────────────────────────────────────────────────
  'anello-dolce-salato': [
    ItinerarySection(
      body:
          'Itinerario nella Pineta San Vitale. Dal centro didattico Ca\' Vecia alla Pialassa Baiona, in tipiche zone umide d\'acqua dolce o salmastra. Escursione facile, adatta a tutti, di circa 4 km percorribile in circa due ore.',
    ),
    ItinerarySection(
      body:
          'Che sorprese può nascondere una semplice passeggiata tra i pini? Molte più di quante immagini! In questo breve itinerario ad anello dal centro didattico Ca\' Vecia alla Pialassa Baiona, l\'acqua dolce incontra la salata, la natura si intreccia con la storia e il presente dialoga con il futuro. Dodici cartelli informativi ti accompagneranno, svelando curiosità sul territorio e sul progetto europeo ACTION.',
    ),
  ],

  'pedalando-immersi-nella-pineta': [
    ItinerarySection(
      body:
          'Partenza: Centro Visita La Bevanella\nArrivo: Centro Visita La Bevanella\nUn percorso che unisce un\'esperienza immersiva nella natura con la visita ad un sito UNESCO e ad un Museo che racconta la storia di Ravenna, città che fu per ben tre volte Capitale.',
    ),
    ItinerarySection(
      title: '1° Tratto',
      body:
          'Dal Centro Visite Bevanella a Sant\'Apollinare in Classe\nUsciti dal centro Visita risaliamo l\'argine del Torrente Bevano; qui la salita è ripida ed è necessario prestare molta attenzione. Continuiamo sull\'argine attraversandolo all\'altezza di Via delle Cave fino all\'entrata della Pineta di Classe, che trovate alla vostra destra. Seguendo le indicazioni tabellari, a volte nascoste dalla vegetazione, con numerazione e l\'indicazione "Basilica di Classe", uscirete dalla pineta per proseguire in via Bosca. Attenzione perché quando attraversate la ferrovia la pista ciclabile prosegue alla vostra destra e la segnaletica è scolorita. Questa conduce in via Battista Morgagni, poi girando a sinistra in via Pescara, dove alla fine troverete la Basilica di Classe.',
    ),
    ItinerarySection(
      title: '2° Tratto',
      body:
          'Da Sant\'Apollinare in Classe al Classis\nUscendo dal cortile posteriore ci troviamo in via Classense; proseguendo per circa 300 metri, attraversando la ferrovia, a destra si trova l\'entrata del Museo Classis.',
    ),
    ItinerarySection(
      title: '3° Tratto',
      body:
          'Dal Classis al Centro Visite Bevanella\nUscendo dal Museo Classis si procede a ritroso fino ad arrivare al Centro Visite Bevanella.',
    ),
  ],

  'pedalando-tra-la-storia': [
    ItinerarySection(
      body:
          'Percorso ad anello con partenza dal Bosco della Mesola, per raggiungere il Castello della Mesola con il suo Museo, l\'Abbazia di Pomposa e ritorno.',
    ),
    ItinerarySection(
      title: '1° Tratto',
      body:
          'Dal Bosco della Mesola al Castello della Mesola e Museo\nPartenza dal parcheggio auto per i visitatori del Bosco della Mesola. Percorriamo via Frassini fino alla fine, poi prendiamo a sinistra la pista ciclabile protetta a fianco della strada Provinciale fino all\'incrocio con via Belmonte, che seguiamo fino all\'Oasi naturale di Torre Abate. Superato il Canale Bianco andiamo a sinistra per risalire l\'argine fino a via Dossone Sud per poi riprendere sempre a sinistra la pista ciclabile protetta di via Biverare; attraversiamo il sottopasso della statale Romea ed eccoci arrivati al Castello.',
    ),
    ItinerarySection(
      title: '2° Tratto',
      body:
          'Dal Castello della Mesola e Museo all\'Abbazia di Pomposa\nUsciamo dal Castello in direzione della Statale Romea e superato il sottopasso riprendiamo il percorso fatto fino all\'incrocio con la strada Provinciale alle spalle del Paese di Bosco Mesola. Andiamo fino al centro del paese e alla rotonda seguiamo per Via I Maggio e via del Mare per poi tenere la sinistra fino all\'incrocio con Via Lovara, alla fine della quale dobbiamo svoltare a destra e poi a sinistra per proseguire in Via Strane. All\'incrocio con via Giralda giriamo a destra e continuiamo fino all\'Abbazia di Pomposa',
    ),
    ItinerarySection(
      title: '3° Tratto',
      body:
          'Dall\'Abbazia di Pomposa al Boscone della Mesola\nUsciamo in direzione di Valle Giralda proseguendo fino alla fine di Via Giralda Centrale, svoltiamo a sinistra in direzione di Bosco Mesola fino a Località Carpani dove giriamo a destra per prendere Via Gigliola fino al parcheggio visitatori del Bosco della Mesola.',
    ),
  ],

  'pedalando-tra-porto-e-salina': [
    ItinerarySection(
      body:
          'Partenza: Parco Naturale di Cervia (Cervia)\nArrivo: Parco Naturale di Cervia (Cervia)\nComuni interessati: Cervia\nUn percorso naturalistico, educativo adatto a tutti e a tutti i mezzi. La maggior parte del percorso è asfaltato e protetto, in alcuni brevi tratti misto veicolare cittadino, con limiti a 30 o 50 km.',
    ),
    ItinerarySection(
      title: '1° Tratto',
      body:
          'Dal Parco Naturale di Cervia alla Casa delle Farfalle\nUsciti dal Parco su via Forlanini alla fine della strada a destra si imbocca la pista ciclabile, ghiaiata nel primo tratto e poi in asfalto, fino a raggiungere la Casa delle Farfalle. Gli ultimi 300 mt sono in strada, con percorso misto veicolare.',
    ),
    ItinerarySection(
      title: '2° Tratto',
      body:
          'Dalla Casa delle Farfalle al MUSA, Museo del Sale\nUscendo a destra dalla Casa delle Farfalle a 300 mt a sinistra troverete via Stazzone, strada in terra battuta che attraversa la pineta fino ad arrivare alla pista ciclabile in asfalto, che fiancheggia via G. di Vittorio. Seguitela fino al ponte sul Canale di Cervia, attraversando anche un semaforo per le biciclette, per svoltare a sinistra dove a pochi metri troverete il MUSA.',
    ),
    ItinerarySection(
      title: '3° Tratto',
      body:
          'Dal MUSA, Museo del Sale al Centro Visita le Saline\nUscendo dal MUSA seguite a sinistra il canale sulla pista ciclabile che lo fiancheggia fino al ponte e sempre a sinistra, su strada a traffico misto, imboccate sulla rotonda via Ospedale. Dopo il passaggio a livello attenzione a mantenere la destra per via Bova, caratterizzata da percorso protetto, alla fine della quale trovate il sottopasso della SS 16 che vi collega con il Centro Visita le Saline. Tutto il percorso è asfaltato.',
    ),
    ItinerarySection(
      title: '4° Tratto',
      body:
          'Dal Centro Visita le Saline al Parco Naturale di Cervia\nPercorrete a ritroso il percorso fino all\'incrocio di via Stazzone proseguendo su via G. di Vittorio rimanendo sulla pista ciclabile che prosegue dopo il passaggio a livello fiancheggiando il Parco Naturale fino all\'entrata da dove siete partiti. Nell\'ultimo tratto il percorso è un po\' sconnesso.',
    ),
  ],

  // ── Itinerari in Bici ─────────────────────────────────────────────────────
  'ciclovia-valli-argine': [
    ItinerarySection(
      body:
          'Partenza: Comacchio o Sant\'Alberto (traghetto)\nArrivo: Comacchio o Sant\'Alberto (traghetto)\nTempo di percorrenza: 5 ore in bicicletta\nLunghezza: 55 km\nComuni interessati: Argenta, Comacchio, Ravenna',
    ),
    ItinerarySection(
      body:
          'La Ciclovia delle Valli di Comacchio è un suggestivo itinerario ciclopedonale che si snoda per circa 55 km nel cuore del Parco del Delta del Po - Emilia-Romagna. Il percorso, in gran parte pianeggiante e adatto a ciclisti di ogni livello, attraversa ambienti di straordinario pregio naturalistico, come specchi d\'acqua salmastra, canali, argini e stazioni di pesca tradizionali.\nI principali punti di partenza dell\'itinerario sono Comacchio e Sant\'Alberto, da cui è possibile intraprendere il percorso ad anello, che offre spettacolari punti di osservazione sulla fauna tipica del Delta del Po',
    ),
    ItinerarySection(
      body:
          'La ciclovia è segnalata ed è percorribile sia in autonomia sia con visite guidate. Rappresenta una delle esperienze più autentiche e coinvolgenti per scoprire, nel pieno rispetto dell\'ambiente, la ricchezza paesaggistica e culturale del territorio.',
    ),
    ItinerarySection(
      body:
          'Nell\'area a sud delle Valli di Comacchio, dalla stazione di pesca Bellocchio a Volta Scirocco si sviluppa per 5,4 km l\'Argine degli Angeli (mappa del percorso), una lingua di terra che si snoda fra le acque delle Valli e rappresenta una straordinaria opportunità per immergersi nella natura, in un contesto ambientale di grande fascino.',
    ),
    ItinerarySection(
      body:
          'La fruizione di questo percorso escursionistico è regolata da orari compatibili con le stagioni: dal 20 marzo al 20 settembre dalle 7.30 alle 20.00 e dal 21 settembre al 19 Marzo dalle 8.00 alle 17.00. Agli estremi dell\'itinerario sono posizionati cancelli d\'accesso. Eventuali limitazioni di accesso, legate ad eventi piovosi, attività di pesca o a esigenze di carattere ambientale, saranno comunicate sul sito www.parcodeltapo.it, dove sono reperibili anche tutte le informazioni turistiche dell\'area.',
    ),
  ],

  'da-valle-a-valle': [
    ItinerarySection(
      body: 'Partenza: Argenta\nArrivo: Comacchio\nLunghezza: 40.7 km\nDislivello: pianeggiante',
    ),
    ItinerarySection(
      body:
          'Partenza dall\'Oasi di Val Campotto, dove ci si può soffermare per una visita al Museo delle Valli con l\'Ecomuseo di Argenta, il Museo della Bonifica e tutta la bellissima area naturalistica delle Valli. Nelle vicinanze anche la storica Pieve di San Giorgio, attorno alla quale si sviluppò il primo nucleo abitato di Argenta.',
    ),
    ItinerarySection(
      body:
          'Una volta lasciate alle spalle le Valli dolci di Argenta, ci inoltriamo attraverso le campagne ferraresi verso le Valli salmastre di Comacchio, potendo ammirare una ricchissima e variegata avifauna, tra cui gli splendidi esemplari di fenicotteri rosa.',
    ),
    ItinerarySection(
      body:
          'Si raggiunge, quindi, l\'argine Agosta, affacciato sugli specchi vallivi e, poco dopo, si entra in Valle Zavelea, ultima tappa prima di scorgere l\'abitato di Comacchio, maestosa città lagunare tra terra e acqua.',
    ),
    ItinerarySection(
      body: 'Fondo: 84% Asfaltato / 16% Non asfaltato\nTipologia Bici: mountain bike, trekking bike',
    ),
  ],

  'lamone': [
    ItinerarySection(
      body: 'Lunghezza: 35 km\nDislivello: pianeggiante',
    ),
    ItinerarySection(
      body:
          'Dalle bellezze storico-culturali di Russi e Bagnacavallo alle suggestive aree naturalistiche del ravennate, lambendo alla fine le acque del Mare Adriatico in cui sfocia il fiume.',
    ),
    ItinerarySection(
      body:
          'Sempre accompagnati dal placido scorrere dell\'acqua, potremo gustarci le rigogliose pianure che caratterizzano la regione, con i campi coltivati, le valli bonificate, le lagune salmastre e le pinete, ma anche emergenze culturali ed architettoniche di assoluto rilievo in cui poter fare qualche piccola sosta.',
    ),
    ItinerarySection(
      body: 'Fondo: asfalto\nTipologia Bici: mountain bike, trekking bike',
    ),
  ],

  'pinete': [
    ItinerarySection(
      body:
          'Lunghezza: 25.1 km\nUn percorso facile e pianeggiante (poco più di 25 chilometri) nel verde delle pinete che si estendono tra Ravenna e Cervia. Le pinete hanno un profondo significato storico e culturale e, seppure fortemente ridotte rispetto all\'antichità, conservano ancora oggi tutto il loro fascino, distinguendosi come elemento predominante del paesaggio costiero dalla foce del fiume Reno fino a Cervia.',
    ),
    ItinerarySection(
      body:
          'Partendo da Milano Marittima, si pedala su piste ciclabili e sterrati facili per tutta la lunghezza del percorso. All\'interno della Pineta di Cervia, poi, perchè non fare tappa alla Casa delle Farfalle? Si tratta di una serra tropicale di oltre 500 mq dove far scoprire ai più piccoli la bellezza di centina di specie di farfalle provenienti da tutto il mondo.',
    ),
    ItinerarySection(
      body:
          'Durante il tragitto di ritorno, invece, di rientro verso Milano Marittima si percorre un tratto sull\'argine del fiume Savio, quasi in corrispondenza della foce.',
    ),
    ItinerarySection(
      body: 'Fondo: asfaltato e sterrato\nTipologia Bici: mountain bike',
    ),
  ],

  'ravenna-cervia': [
    ItinerarySection(
      body: 'Lunghezza: 73.8 km',
    ),
    ItinerarySection(
      body:
          'Poco meno di 75 chilometri per un itinerario ad anello, con partenza ed arrivo a Ravenna, che tocca la costa e si perde negli incantati scenari della natura offerta dalla Pineta di Classe e dal Parco Naturale di Cervia.',
    ),
    ItinerarySection(
      body:
          'Dal centro di Ravenna si arriva in poco tempo nel cuore della Pineta di Classe, riserva naturale del Parco regionale del Delta del Po che, assieme a quella di Cervia, rappresenta un relitto della più antica pineta di Ravenna, ed è abitata da diverse specie di uccelli come la cinciallegra, la gazze e il gufo comune.\nUn po\' di strade sterrate ed eccoci nel Parco Naturale di Cervia, un\'oasi nel verde di 32 ettari all\'interno della millenaria pineta di Milano Marittima. Da qui la pedalata continua fino al meraviglioso scenario offerto dalle vasche e dai canali delle saline, di origine etrusca e tuttora in funzione, intervallate da stradine con i tipici "casoni" dei pescatori. Quindi il ritorno verso Ravenna per strade interne.',
    ),
    ItinerarySection(
      body: 'Fondo: asfaltato e sterrato\nTipologia Bici: mountain bike, gravel',
    ),
  ],

  'sterrati-savio': [
    ItinerarySection(
      body: 'Partenza: Cervia\nArrivo: Cervia\nLunghezza: 67.3 km\nUn tranquillo itinerario in Romagna, con partenza ed arrivo a Cervia alla scoperta degli sterrati lungo il Savio, il più lungo fiume nel territorio, tributario del Mare Adriatico.',
    ),
    ItinerarySection(
      body:
          'Partendo da Cervia, il percorso si snoda lungo la Pineta di Milano Marittima prima di imboccare il percorso ciclabile che corre lungo il fiume, nell\'omonimo parco naturale, casa di una ricchissima varietà di uccelli e animali. Si percorrono poi diversi chilometri di suggestive stradine, che conducono fino a Cesena, antica capitale malatestiana.\nSeguendo l\'argine destro del fiume, grazie a sterrati, singletracks e stradine secondarie, si farà ritorno verso Cervia transitando attraverso lo splendido scenario offerto dalle sue Saline, stazione Sud del Parco Delta del Po ed area protetta dove vivono fenicotteri, avocette, aironi e cavalieri d\'Italia.',
    ),
    ItinerarySection(
      body: 'Fondo: asfaltato e sterrato\nTipologia Bici: mountain bike, gravel',
    ),
  ],

  // ── Birdwatching ─────────────────────────────────────────────────────────
  'birdwatching-campotto-argenta': [
    ItinerarySection(
      title: 'Valle Santa',
      body:
          'Il percorso di Valle Santa compie l\'intero perimetro della bella palude d\'acqua dolce, per una lunghezza di circa 8,5 chilometri.\nDall\'ingresso si prosegue verso sud, fino a giungere ai camminamenti schermati che permettono di osservare l\'avifauna in sosta nei prati umidi ai margini della palude, ove è possibile osservare, tra gli altri, spatole, sgarze ciuffetto, nitticore, alzavole e mestoloni, cavalieri d\'Italia e pittime reali.',
    ),
    ItinerarySection(
      body:
          'Si costeggiano poi estesi canneti su cui volteggia il falco di palude e da cui in primavera giungono i canti degli acrocefalini e i richiami di porciglione, voltolino e schiribilla. Il percorso prosegue sull\'argine del torrente Sillaro, fino a svoltare lungo la riva della palude che costeggia il bosco del Traversante, sede della garzaia. Qui, tra salici e pioppi ai cui rami sono appesi i nidi dei pendolini, si osservano spettacolari scorci della palude, con canneti ove nidificano gli aironi rossi ed estesi lamineti, su cui volteggiano i mignattini piombati.',
    ),
  ],

  'birdwatching-saline': [
    ItinerarySection(
      body:
          'La Salina di Cervia rappresenta la stazione più a Sud del Parco Regionale del Delta del Po. E\' un ambiente di elevato interesse naturalistico e paesaggistico, tanto da essere stato inserito come Zona Umida di Importanza Internazionale nella Convenzione di Ramsar e dal 1979 è divenuto Riserva Naturale dello Stato. La Salina si estende su una superficie di 827 ettari ed è percorsa all\'interno da una fitta rete di canali.',
    ),
    ItinerarySection(
      body:
          'Sotto il profilo avifaunistico l\'ambiente delle saline è popolato da specie come il Fenicottero rosa, il Cavaliere d\'Italia, l\'Avocetta, gli aironi tipici del Delta del Po e altre specie protette. Grazie alle sue caratteristiche è zona di sosta e nidificazione per numerose specie di uccelli che occupano i piccoli argini e gli isolotti che si formano all\'interno delle vasche. Le specie regolarmente nidificanti in questo sito e quindi visibili nel periodo primavera - estate, sono Volpoca e Germano reale tra gli Anatidi, mentre tra i Limicoli si osservano Cavaliere d\'Italia, Avocetta, Fratino, Pavoncella e Pettegola. Tra i Caradriformi nidificano Gabbiano corallino e Gabbiano reale, accompagnati da Sternidi come Fraticello e Sterna comune. In autunno e nella stagione invernale invece la salina si riempie di Fischioni, Alzavole, Mestoloni, Codoni, Canapiglie e Germani reali. Per quanto riguarda i rapaci si possono vedere Poiana e Falco di palude.',
    ),
    ItinerarySection(
      title: 'Caratteristiche',
      body:
          'Possibilità di avvistare 60 specie\nPunti di osservazione, mascheramenti, torrette, capanni\nBuona agibilità, anche in caso di pioggia',
    ),
    ItinerarySection(
      title: 'Modalità di Fruizione',
      body:
          'Aperto da marzo a novembre con orari diversi in base alla stagione\nOrario consigliato: primo mattino e tardo pomeriggio\nDurata: minimo due ore e trenta minuti\nAccesso a pagamento\nPercorsi parzialmente accessibili ai disabili',
    ),
    ItinerarySection(
      title: 'Servizi',
      body:
          'Centro visite, museo e bookshop\nParcheggio\nPunto ristoro\nPer le visite guidate possibilità di noleggio binocoli e biciclette',
    ),
  ],

  'birdwatching-baiona': [
    ItinerarySection(
      title: 'Punte Alberete',
      body:
          'Il percorso di visita a Punte Alberete è un sentiero pedonale ad anello di circa 2 chilometri, che parte dal parcheggio sulla statale 309 Romea, a ridosso del canale Fossatone. Il primo tratto attraversa il bosco primigenio allagato di frassini e salici; si prosegue poi nella parte più aperta della palude, tra canneti, chiari e prati umidi, fino a giungere all\'area attrezzata con schermature e il capanno per il birdwatching.\n\nQui si ha la certezza di osservare specie straordinarie, tutte nidificanti nella palude. Nitticore e sgarze ciuffetto involano dai salici, mentre gli aironi rossi si alzano dai folti canneti; i chiari sono popolati da morette tabaccate e fistioni turchi, che in primavera compiono spettacolari voli di corteggiamento. Davanti al capanno è facile osservare i marangoni minori e i mignattai, mentre si alimentano nelle acque limpide. Terminato il percorso è possibile raggiungere, poco più a nord, la Valle Mandriole, dalla cui alta torre panoramica si domina la grande garzaia insediata tra le canne e i saliconi.',
    ),
    ItinerarySection(
      title: 'Pineta di San Vitale e Pialassa della Baiona',
      body:
          'Il percorso, che inizia presso la Ca\' Vecia nella pineta di San Vitale, è un sentiero pedonale di circa 4 chilometri. Il primo tratto si addentra nella pineta, che ad un tratto si apre nella spettacolare bassa del Pirottolo, lingua d\'acqua e canneti che serpeggia tra i pini domestici. Oltre la bassa, il bosco diviene più termofilo, mentre ci si avvicina alle rive della pialassa della Baiona, come ad antiche spiagge. Qui è possibile seguire un argine che si addentra nella laguna, lungo il chiaro del Comune, stagno salmastro in cui sostano migliaia di uccelli di passo e dove nidificano volpoca, fistione turco e canapiglia; qui, inoltre, si alimentano regolarmente marangone minore, mignattaio e spatola.\nSul lato opposto si apre la Polalonga, parte di laguna sui cui dossi, appositamente realizzati, nidificano gabbiano roseo, gabbiano corallino, sterna zampenere, sterna comune e fraticello. Il ritorno attraversa un\'altra singolare zona umida salmastra, la buca del Cavedone, che si insinua nella pineta collegando la bassa del Pirottolo alla pialassa.',
    ),
  ],

  'birdwatching-valli-comacchio': [
    ItinerarySection(
      title: 'Dalla stazione da pesca Foce alla Salina di Comacchio, a Valle di Fossa Porto, a Valle Zavelea',
      body:
          'Il percorso, di circa 9 chilometri, inizia dalla Stazione da Pesca Foce. Voltando a sinistra si arriva a Valle Uccelliera, valle salmastra con stormi di anatre di diverse specie, soprattutto in inverno e durante le migrazioni. Proseguendo si giunge alla Salina di Comacchio, dove si osservano moltissime specie di limicoli; vi nidificano gabbiani e sterne e vi hanno sede la più grande colonia italiana di fenicotteri e l\'unica colonia italiana di spatole.\n\nAncora da Stazione Foce, voltando a destra, si può percorrere l\'argine Fossa Foce che porta in 5 chilometri verso Valle Zavelea. Qui è possibile avvistare le più importanti specie delle valli di Comacchio. Al termine, si entra in Valle Zavelea, fino alla torretta da cui si osserva la palude, con estesi canneti (in cui nidifica il falco di palude) e con velme fangose ove nidificano fraticelli, sterne comuni, sterne zampenere e la rarissima pernice di mare.\nInfine, sempre da Stazione Foce è possibile imbarcarsi per la visita delle Valli; dal battello, che conduce ad antichi casoni da pesca, si effettuano interessanti osservazioni. Il percorso prosegue lungo la parte settentrionale di Valle Fossa di Porto, con molti dossi che ospitano importanti colonie di caradriformi.',
    ),
    ItinerarySection(
      title: 'Valle Furlana: da Boscoforte a Volta Scirocco',
      body:
          'Valle Furlana è la porzione meridionale delle Valli di Comacchio, uno dei santuari italiani del birdwatching. Fenicottero, spatola, airone rosso, gru, volpoca, sterna maggiore, falco pescatore, aquila anatraia maggiore, sono alcune delle rarità che è possibile osservare in questo affascinante itinerario. La Valle Furlana è raggiungibile, attraverso il suggestivo traghetto sul fiume Reno, da Sant\'Alberto, sede del Centro visite del Parco.\nIl percorso sull\'argine, che comincia all\'altezza della celebre penisola di Boscoforte, si snoda per circa 6,5 chilometri incontro al mare Adriatico, fino a Volta Scirocco.\nSi raggiunge dapprima la Lavadena, con un mosaico di dossi ricoperti di vegetazione alofila su cui nidificano importanti colonie di gabbiani, sterne e limicoli.\nPiù oltre, le acque basse della Scorticata ospitano regolarmente migliaia di anatidi, limicoli e ardeidi. Dai capanni attrezzati della tranquilla golena di Volta Scirocco è possibile osservare, tra gli altri, spatole, aironi rossi, cavalieri d\'Italia e canapiglie.',
    ),
  ],

  'birdwatching-volano-mesola-goro': [
    ItinerarySection(
      title: 'Sull\'argine del Po di Goro',
      body:
          'Il percorso sull\'argine del Po di Goro, lungo circa 25 chilometri, parte dal Centro visite del Castello della Mesola e, passata la Sacca di Goro, giunge alla Lanterna Vecchia, in Valle Gorino. Il primo tratto costeggia un lungo tratto del Po, tra boschi ripariali e golene allagate, mentre a destra si susseguono campagne coltivate, pioppeti e lembi di boschi termofili su cui volteggia il lodolaio. Presso Goro la golena si allarga in una bella palude, Valle Dindona, che ospita una garzaia di nitticora, garzetta, sgarza ciuffetto e airone guardabuoi. Poco oltre, la vista si allarga sul piatto paesaggio della Sacca, un grande braccio di mare racchiuso da una lunga lingua di sabbia protesa nell\'Adriatico. Qui sostano in inverno migliaia di uccelli, mentre in primavera è possibile osservare tutte le specie di gabbiani e sterne nidificanti nel Delta. Il percorso termina presso il vecchio faro, da cui si dominano i vasti canneti di Valle Gorino, originati dalle acque dolci delle foci del Po; qui nidificano falco di palude e airone rosso, facilmente osservabili in volo o ai bordi dei canneti; nei chiari fangosi sostano stormi di limicoli e anatre.',
    ),
    ItinerarySection(
      title: 'Valle Porticino-Canneviè e Valli Bertuzzi',
      body:
          'Il percorso all\'interno di Valle Porticino - Canneviè è molto ben attrezzato con schermature e capanni per l\'osservazione degli uccelli; vi si accede dal Casone di Porticino o dal Casone di Canneviè.\nLa Valle salmastra, ricca di vegetazione alofila, ospita numerose specie ornitiche, limicoli, in particolare cavalieri d\'Italia, anatre e centinaia di folaghe. La visita alla stazione può proseguire in bicicletta lungo la strada Acciaioli, che costeggia l\'argine orientale delle splendide Valli Bertuzzi, la laguna salmastra meglio conservata del Delta.\nSui numerosi dossi ricoperti di salicornia nidificano importanti colonie di gabbiani e sterne, che è possibile osservare dalla strada durante i continui spostamenti verso l\'Adriatico e i prati che separano le Valli dal mare, che costituiscono i principali ambienti di alimentazione per le diverse specie. Dalla strada è anche possibile osservare grandissimi stormi di fenicotteri in sosta nelle tranquille acque della valle, assieme ad aironi bianchi maggiori, aironi cenerini, garzette e cormorani.',
    ),
  ],

  'birdwatching-vallette-di-ostellato': [
    ItinerarySection(
      title: 'Le Vallette di Ostellato',
      body:
          'Le Vallette di Ostellato sono un complesso di boschi e paludi d\'acqua dolce, lungo 15 km e compreso tra due grandi canali di bonifica. Il percorso parte dal Villaggio Natura ed è lungo circa 4,5 chilometri; è percorribile a piedi, in bicicletta, con mezzi elettrici o in auto; alla fine del percorso è possibile proseguire ancora, soltanto a piedi, fra macchie di prugnolo, sambuco e tamerice, verso valle Zagno. In questa parte meglio conservata e protetta, vi sono alcuni osservatori per birdwatching, costituiti sia da schermature, sia da capanni.',
    ),
    ItinerarySection(
      body:
          'Uno degli osservatori principali è nei pressi della voliera delle cicogne bianche, un altro si affaccia su di un chiaro della palude, da cui è possibile osservare le nidificazioni di pendolino, svasso maggiore e airone cenerino. Le Vallette sono un buon punto di osservazione dell\'avifauna durante tutto l\'anno; ospitano tutte le specie di aironi europei, numerose specie di anatre e limicoli, tra cui numerosi cavalieri d\'Italia, ed il già citato nucleo di cicogna bianca.',
    ),
  ],
};
