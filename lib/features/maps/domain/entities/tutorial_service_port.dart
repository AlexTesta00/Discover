abstract class TutorialServicePort {
  Future<bool> shouldShowItineraryTutorial();
  Future<void> markItineraryTutorialSeen();
}