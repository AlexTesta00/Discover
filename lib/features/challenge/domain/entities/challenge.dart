import 'dart:convert';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String image;
  final int xp;
  final int flamingo;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.xp,
    required this.flamingo,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      xp: (map['xp'] as num).toInt(),
      flamingo: (map['flamingo'] as num).toInt(),
    );
  }

  static List<Challenge> listFromJson(String source) {
    final data = json.decode(source) as List<dynamic>;
    return data.map((e) => Challenge.fromMap(e as Map<String, dynamic>)).toList();
  }
}
