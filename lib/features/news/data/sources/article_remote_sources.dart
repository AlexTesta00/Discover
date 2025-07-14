
import 'package:discover/features/news/data/models/article_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Stream<List<ArticleModel>> loadArticleFromDatabase() => Supabase.instance.client.from('news').stream(
    primaryKey: ['id'],
).map((data) => data.map((articleMap) => ArticleModel.fromMap(articleMap)).toList());