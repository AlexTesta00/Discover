import 'package:discover/features/gamification/domain/entities/level.dart';

final List<Level> defaultLevels = [
    Level(name: 'Scout delle orme',  xpToReachLevel: 0,    imageUrl: 'assets/levels/scout.png'),
    Level(name: 'Raccoglitore di indizi',  xpToReachLevel: 100,  imageUrl: 'assets/levels/clues.png'),
    Level(name: 'Cercatore di piume',  xpToReachLevel: 200,  imageUrl: 'assets/levels/feathers.png'),
    Level(name: 'Osservatore di Nidi',  xpToReachLevel: 300,  imageUrl: 'assets/levels/nest.png'),
    Level(name: 'Tracciatore di scie',  xpToReachLevel: 450,  imageUrl: 'assets/levels/trails.png'),
    Level(name: 'Cacciatore di rarità',  xpToReachLevel: 500, imageUrl: 'assets/levels/hunter.png'),
    Level(name: 'Catalogatore di specie',  xpToReachLevel: 600, imageUrl: 'assets/levels/animals.png'),
    Level(name: 'Esperto di Habitat',  xpToReachLevel: 800, imageUrl: 'assets/levels/habitat.png'),
    Level(name: 'Maestro di avvistamenti',  xpToReachLevel: 1000, imageUrl: 'assets/levels/sightings.png'),
    Level(name: 'Leggenda della ricerca', xpToReachLevel: 1200, imageUrl: 'assets/levels/legend.png'),
];