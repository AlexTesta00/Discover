import 'package:discover/features/character/domain/entities/character.dart';

class Challenge {
  final String id;
  final String characterId;
  final String title;
  final String description;
  final List<String> labels;
  final int xp;
  final int fenicotteri;
  final bool requiresPhoto;
  final bool isActive;
  final DateTime? startAt;
  final DateTime? endAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Character character;

  const Challenge({
    required this.id,
    required this.characterId,
    required this.title,
    required this.description,
    required this.labels,
    required this.xp,
    required this.fenicotteri,
    required this.requiresPhoto,
    required this.isActive,
    required this.startAt,
    required this.endAt,
    required this.createdAt,
    required this.updatedAt,
    required this.character,
  });

  factory Challenge.fromMap(Map<String, dynamic> m) {
    return Challenge(
      id: m['id'] as String,
      characterId: m['character_id'] as String,
      title: m['title'] as String,
      description: m['description'] as String,
      labels: (m['labels'] as List?)?.cast<String>() ?? const <String>[],
      xp: (m['xp'] as num).toInt(),
      fenicotteri: (m['fenicotteri'] as num).toInt(),
      requiresPhoto: m['requires_photo'] as bool,
      isActive: m['is_active'] as bool,
      startAt: m['start_at'] != null ? DateTime.parse(m['start_at'] as String) : null,
      endAt:   m['end_at']   != null ? DateTime.parse(m['end_at'] as String)   : null,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      character: Character.fromMap(m['character'] as Map<String, dynamic>),
    );
  }
}
