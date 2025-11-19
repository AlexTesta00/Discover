class FriendRequest {
  final String id;
  final String fromEmail;
  final String toEmail;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? fromAvatarUrl;

  FriendRequest({
    required this.id,
    required this.fromEmail,
    required this.toEmail,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.fromAvatarUrl,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> m) {
    final fromProfile = m['from_profile'] as Map<String, dynamic>?;

    return FriendRequest(
      id: m['id'] as String,
      fromEmail: m['from_email'] as String,
      toEmail: m['to_email'] as String,
      status: m['status'] as String,
      createdAt: DateTime.parse(m['created_at'] as String),
      respondedAt: m['responded_at'] == null
          ? null
          : DateTime.parse(m['responded_at'] as String),
      fromAvatarUrl: fromProfile?['avatar_url'] as String?,
    );
  }
}
