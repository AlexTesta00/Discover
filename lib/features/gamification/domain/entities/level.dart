class Level {
  final int grade;
  final String name;
  final int xpToReach;

  Level({required this.grade, required this.name, required this.xpToReach});

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      grade: json['grade'] as int,
      name: json['name'] as String,
      xpToReach: json['xp_to_reach'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'grade': grade,
    'name': name,
    'xp_to_reach': xpToReach,
  };

  static double progressToNextLevel(int currentXp, int nextLevelXp) {
    if (nextLevelXp <= 0) return 1.0;
    final progress = (currentXp / nextLevelXp).clamp(0.0, 1.0);
    return progress;
  }

}
