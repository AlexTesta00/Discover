import 'package:discover/features/news/domain/entities/article.dart';

class ArticleModel extends Article{
  ArticleModel({
    required super.date,
    required super.title,
    required super.description,
    required super.image,
  });

  factory ArticleModel.fromMap(Map<String, dynamic> map){
    return ArticleModel(
      date: DateTime.parse(map['created_at']), 
      title: map['title'] as String, 
      description: map['description'] as String, 
      image: map['image'] as String,
    );
  }

  Article toEntity() => Article(
    date: date, 
    title: title, 
    description: description, 
    image: image
  );
}