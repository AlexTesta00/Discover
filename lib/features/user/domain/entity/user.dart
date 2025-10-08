import 'package:discover/features/gamification/domain/entities/level.dart';

class User {
  User({
    required this.email,
    required this.avatarImage,
    required this.backgroundImage,
    required this.xp,
    required this.balance,
    required this.level,
    required this.nextLevel,
  });

  //TODO: add friends and challenges
  final String email;
  final String avatarImage;
  final String backgroundImage;
  final int xp;
  final int balance;
  final Level level;
  Level nextLevel;

  factory User.fromRpcRow(Map<String, dynamic> row) => User(
    email: row['email'] as String,
    avatarImage: row['avatar_image'] as String,
    backgroundImage: row['background_image'] as String,
    xp: row['xp'] as int,
    balance: row['balance'] as int,
    level: Level.fromJson(row['level'] as Map<String, dynamic>),
    nextLevel: (row['next_level'] == null)
        ? Level(
            grade: row['level']['grade'],
            name: row['level']['name'],
            xpToReach: row['level']['xp_to_reach'],
          )
        : Level.fromJson(row['next_level'] as Map<String, dynamic>),
  );
}
