class CharacterLite {
  final String id;
  final String name;
  final String imageAsset;

  const CharacterLite({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  factory CharacterLite.fromMap(Map<String, dynamic> m) {
    return CharacterLite(
      id: m['id'] as String,
      name: m['name'] as String,
      imageAsset: m['image_asset'] as String,
    );
  }
}
