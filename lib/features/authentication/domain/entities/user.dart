class User {
  final String email;
  final String password;
  final String avatarKey;
  final String backgroundKey;
  final int xpReached;

  User({
    required this.email,
    required this.password,
    required this.avatarKey,
    required this.backgroundKey,
    required this.xpReached,
  });

  factory User.newUser(String email, String password) => User(
    email: email,
    password: password,
    avatarKey: 'assets/avatar/avatar_9.png',
    backgroundKey: 'assets/background/default.png',
    xpReached: 0,
  );

  factory User.newUserWithAvatar(String email, String password, String avatar) => User(
    email: email,
    password: password,
    avatarKey: avatar,
    backgroundKey: 'assets/background/default.png',
    xpReached: 0,
  );

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      email: map['email'] as String,
      password: map['password'] as String,
      avatarKey: map['avatar_key'] as String? ?? '',
      backgroundKey: map['background_key'] as String? ?? '',
      xpReached: map['xp_reached'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'avatar_key': avatarKey,
      'background_key': backgroundKey,
      'xp_reached': xpReached,
    };
  }
}
