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
}