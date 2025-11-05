class Collectible {
  final String collectibleId;
  final String characterId;
  final String characterName;
  final String collectibleName;
  final String asset;
  final DateTime? acquiredAt;

  Collectible({
    required this.collectibleId,
    required this.characterId,
    required this.characterName,
    required this.collectibleName,
    required this.asset,
    this.acquiredAt,
  });

  factory Collectible.fromMyMap(Map<String, dynamic> m) => Collectible(
        collectibleId: m['collectible_id'] as String,
        characterId: m['character_id'] as String,
        characterName: m['character_name'] as String,
        collectibleName: m['collectible_name'] as String,
        asset: m['asset'] as String,
        acquiredAt: DateTime.parse(m['acquired_at'] as String),
      );

  factory Collectible.fromMissingMap(Map<String, dynamic> m) => Collectible(
        collectibleId: m['collectible_id'] as String,
        characterId: m['character_id'] as String,
        characterName: m['character_name'] as String,
        collectibleName: m['collectible_name'] as String,
        asset: m['asset'] as String,
        acquiredAt: null,
      );
}
