class Profile {
  final String id;
  final String email;
  final String avatarUrl;
  final String backgroundUrl;
  final int xp;

  Profile({
    required this.id,
    required this.email,
    required this.avatarUrl,
    required this.backgroundUrl,
    required this.xp,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatar_url'] as String? ?? '',
      backgroundUrl: map['background_url'] as String? ?? '',
      xp: map['xp'] is int
          ? map['xp'] as int
          : int.tryParse(map['xp']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'avatar_url': avatarUrl,
      'background_url': backgroundUrl,
      'xp': xp,
    };
  }
}
