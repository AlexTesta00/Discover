class ChallengeSubmissionItem {
  final DateTime completedAt;
  final String challengeTitle;
  final String? photoUrl;

  const ChallengeSubmissionItem({
    required this.completedAt,
    required this.challengeTitle,
    this.photoUrl,
  });
}
