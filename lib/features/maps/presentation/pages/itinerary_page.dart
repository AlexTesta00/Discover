import 'package:discover/features/maps/data/itinerary_data.dart';
import 'package:discover/features/maps/domain/entities/itinerary.dart';
import 'package:discover/features/maps/presentation/pages/itinerary_detail_page.dart';
import 'package:flutter/material.dart';

class ItineraryPage extends StatelessWidget {
  const ItineraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: itineraryGroups.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F2),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F6F2),
          foregroundColor: Colors.black87,
          elevation: 0,
          title: const Text('Itinerari', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.black54,
            tabs: itineraryGroups
                .map(
                  (g) => Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(g.icon, size: 16, color: g.color),
                        const SizedBox(width: 6),
                        Text(g.label),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        body: TabBarView(children: itineraryGroups.map((g) => _ItineraryTab(group: g)).toList()),
      ),
    );
  }
}

const _itineraryNames = <String, String>{
  // Itinerari per Stazioni
  'campotto-argenta': 'Campotto di Argenta',
  'trepponti': 'Centro Storico di Comacchio',
  'pineta-classe-saline': 'Pineta di Classe - Salina di Cervia',
  'punte-alberete': 'Pineta San Vitale - Piallasse di Ravenna',
  'calle-baiona': 'Valli di Comacchio',
  'volano-mesola-goro': 'Volano Mesola Goro',
  // Itinerari in Bici
  'ciclovia-valli-argine': 'Ciclovia delle Valli e Argine degli Angeli',
  'da-valle-a-valle': 'Da Valle a Valle',
  'lamone': 'Lungo il Fiume Lamone',
  'pinete': 'Pedalando nelle Pinete di Ravenna',
  'ravenna-cervia': 'I Parchi tra Ravenna e Cervia',
  'sterrati-savio': 'Sugli sterrati lungo il Savio',
};

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab({required this.group});
  final ItineraryGroup group;

  String _nameFromPath(String path) {
    final stem = path.split('/').last.replaceAll('.geojson', '');
    if (_itineraryNames.containsKey(stem)) return _itineraryNames[stem]!;
    return stem.split('-').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (group.assetPaths.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(group.icon, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            const Text('Nessun itinerario disponibile', style: TextStyle(color: Colors.black45)),
          ],
        ),
      );
    }

    final sorted = [...group.assetPaths]..sort((a, b) => _nameFromPath(a).compareTo(_nameFromPath(b)));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final name = _nameFromPath(sorted[i]);
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ItineraryDetailPage(
                name: name,
                assetPath: sorted[i],
                color: group.color,
              ),
            ),
          ),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Colors.black26)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: group.color),
                  Center(
                    child: Icon(group.icon, size: 90, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withValues(alpha: 0.75), Colors.transparent],
                        stops: const [0.0, 0.65],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
