class EventItem {
  final String ownerEmail;
  final String description;
  final DateTime createdAt;

  EventItem({
    required this.ownerEmail,
    required this.description,
    required this.createdAt,
  });

  factory EventItem.fromMap(Map<String, dynamic> m) => EventItem(
    ownerEmail: m['owner_email'] as String,
    description: m['description'] as String,
    createdAt: DateTime.parse(m['created_at'] as String),
  );
}
