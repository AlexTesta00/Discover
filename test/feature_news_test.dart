import 'package:discover/features/news/data/models/article_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:discover/features/news/domain/entities/article.dart';

void main() {

  group('Article entity', () {
    test('should correctly hold values', () {
      final date = DateTime(2024, 7, 14);
      final article = Article(
        date: date,
        title: 'Test Title',
        description: 'This is a description',
        image: 'https://example.com/image.png',
      );

      expect(article.date, date);
      expect(article.title, 'Test Title');
      expect(article.description, 'This is a description');
      expect(article.image, 'https://example.com/image.png');
    });
  });

    group('ArticleModel', () {
    test('should convert from map correctly', () {
      final map = {
        'created_at': '2025-07-14T10:00:00.000Z',
        'title': 'Model Title',
        'description': 'Some description',
        'image': 'https://example.com/image.jpg',
      };

      final model = ArticleModel.fromMap(map);

      expect(model.title, 'Model Title');
      expect(model.description, 'Some description');
      expect(model.image, 'https://example.com/image.jpg');
      expect(model.date, DateTime.parse(map['created_at']!));
    });

    test('should convert to entity correctly', () {
      final model = ArticleModel(
        date: DateTime(2025, 7, 14),
        title: 'Entity Title',
        description: 'Entity description',
        image: 'https://example.com/image.jpg',
      );

      final entity = model.toEntity();

      expect(entity.title, model.title);
      expect(entity.description, model.description);
      expect(entity.image, model.image);
      expect(entity.date, model.date);
    });
  });

}