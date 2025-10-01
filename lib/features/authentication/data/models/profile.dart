class Profile {
  final String id;
  final String email;
  final String avatarUrl;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    required this.email,
    required this.avatarUrl,
    required this.updatedAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatar_url'] as String? ?? '',
      updatedAt: map['updated_at'] != null
            ? DateTime.tryParse(map['updated_at'] as String)
            : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'avatar_url': avatarUrl,
    };
  }
}