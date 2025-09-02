import 'dart:convert';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String image;
  final int xp;
  final int flamingo;
  final List<String> expectedLabels;
  final double minConfidence;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.xp,
    required this.flamingo,
    this.expectedLabels = const [],
    this.minConfidence = 0.6,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      xp: (map['xp'] as num).toInt(),
      flamingo: (map['flamingo'] as num).toInt(),
      expectedLabels: (map['expectedLabels'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      minConfidence: (map['minConfidence'] as num?)?.toDouble() ?? 0.6,
    );
  }

  static List<Challenge> listFromJson(String source) {
    final data = json.decode(source) as List<dynamic>;
    return data.map((e) => Challenge.fromMap(e as Map<String, dynamic>)).toList();
  }
}
