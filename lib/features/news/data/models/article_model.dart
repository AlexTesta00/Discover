import 'package:discover/features/news/domain/entities/article.dart';

class ArticleModel extends Article {
  ArticleModel({
    required super.date,
    required super.title,
    required super.description,
    required super.image,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    final dateStr = (map['date'] ?? map['created_at']) as String?;
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.fromMillisecondsSinceEpoch(0);

    final title = (map['title'] ?? '') as String;

    final rawDesc = (map['content_text'] ?? map['description'] ?? '') as String;
    final description = rawDesc.trim();

    String pickCoverImage(dynamic v) {
      if (v is List && v.isNotEmpty) {
        final first = v.first;
        if (first is String) return first;
      }
      return (map['image'] ?? '') as String? ?? '';
    }

    final image = pickCoverImage(map['images']);

    return ArticleModel(
      date: date,
      title: title,
      description: description,
      image: image,
    );
  }

  Article toEntity() => Article(
        date: date,
        title: title,
        description: description,
        image: image,
      );
}
