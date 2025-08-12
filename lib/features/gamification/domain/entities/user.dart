import 'dart:convert';

import 'package:discover/features/gamification/domain/entities/flamingo.dart';
import 'package:discover/features/gamification/domain/entities/level.dart';
import 'package:discover/features/gamification/domain/repository/level_catalog.dart';

class User {

  String email;
  final List<Level> levels;
  Level currentLevel;
  Level? nextLevel;
  final Flamingo amount;
  int xpReached;

  User._({
    required this.email,
    required this.levels,
    required this.currentLevel,
    required this.nextLevel,
    required this.amount,
    required this.xpReached,
  });


  factory User({
    String? email,
    String? Function()? emailProvider,
    List<Level>? levels,
    Level? currentLevel,
    Level? nextLevel,
    Flamingo? amount,
    int xpReached = 0,
  }) {
    final resolvedEmail = email ?? (emailProvider?.call() ?? '');
    final resolvedAmount = amount ?? Flamingo();
    final resolvedXp = xpReached;

    final baseLevels = levels ?? defaultLevels;
    final resolvedLevels = List<Level>.from(baseLevels)
      ..sort((a, b) => a.xpToReachLevel.compareTo(b.xpToReachLevel));

    final resolvedCurrent =
        currentLevel ?? _highestReachableLevel(resolvedXp, resolvedLevels);
    final resolvedNext =
        nextLevel ?? _nextByXp(resolvedXp, resolvedLevels);

    return User._(
      email: resolvedEmail,
      levels: resolvedLevels,
      currentLevel: resolvedCurrent,
      nextLevel: resolvedNext,
      amount: resolvedAmount,
      xpReached: resolvedXp,
    );
  }

  Level? computeNextLevel() => _nextByXp(xpReached, levels);

  void addFlamingo(int flamingo) => amount.addFlamingo(flamingo);

  void removeFlamingo(int flamingo) => amount.removeFlamingo(flamingo);

  void addXp(int xp) {
    assert(xp > 0);
    xpReached += xp;
    _updateLevels();
  }

  void _updateLevels() {
    currentLevel = _highestReachableLevel(xpReached, levels);
    nextLevel = _nextByXp(xpReached, levels);
  }

  static Level _highestReachableLevel(int xp, List<Level> levels) {
    Level candidate = levels.first;
    for (final lvl in levels) {
      if (xp >= lvl.xpToReachLevel) {
        candidate = lvl;
      } else {
        break;
      }
    }
    return candidate;
  }

  static Level? _nextByXp(int xp, List<Level> levels) {
    for (final lvl in levels) {
      if (xp < lvl.xpToReachLevel) return lvl;
    }
    return null;
  }


  Map<String, dynamic> toJson() => {
      'email': email,
      'xpReached': xpReached,
      'amount': amount.amount,
      'currentLevelName': currentLevel.name,
      'levels': levels
          .map((l) => {
                'name': l.name,
                'xpToReachLevel': l.xpToReachLevel,
                'imageUrl': l.imageUrl,
              })
          .toList(),
  };

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJson(Map<String, dynamic> map) {
    final levels = (map['levels'] as List<dynamic>?)
            ?.map((e) => Level(
                  name: e['name'] as String,
                  xpToReachLevel: e['xpToReachLevel'] as int,
                  imageUrl: e['imageUrl'] as String,
                ))
            .toList() ??
        defaultLevels;

    final xp = (map['xpReached'] as int?) ?? 0;
    final currentName = map['currentLevelName'] as String?;
    final current = currentName != null
        ? levels.firstWhere(
            (l) => l.name == currentName,
            orElse: () => _highestReachableLevel(xp, levels),
          )
        : _highestReachableLevel(xp, levels);

    return User(
      email: map['email'] as String? ?? '',
      levels: levels,
      xpReached: xp,
      amount: Flamingo(amount: (map['amount'] as int?) ?? 0),
      currentLevel: current,
    );
  }

  factory User.fromJsonString(String jsonStr) =>
      User.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}
