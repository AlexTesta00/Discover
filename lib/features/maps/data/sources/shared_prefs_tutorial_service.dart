import 'package:discover/features/maps/domain/entities/tutorial_service_port.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsTutorialService implements TutorialServicePort {
  static const _kItineraryKey = 'has_seen_itinerary_tutorial';

  @override
  Future<bool> shouldShowItineraryTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_kItineraryKey) ?? false);
  }

  @override
  Future<void> markItineraryTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kItineraryKey, true);
  }
}
