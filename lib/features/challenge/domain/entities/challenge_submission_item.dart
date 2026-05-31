class ChallengeSubmissionItem {
  final DateTime completedAt;
  final String challengeTitle;
  final String? photoUrl;
  final bool requiresPhoto;
  final String characterImageAsset;

  const ChallengeSubmissionItem({
    required this.completedAt,
    required this.challengeTitle,
    required this.requiresPhoto,
    required this.characterImageAsset,
    this.photoUrl,
  });
}
