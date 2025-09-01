import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:discover/features/news/data/models/article_model.dart';

final _client = Supabase.instance.client;

Future<List<ArticleModel>> fetchArticlesFromBucket({
  String bucket = 'news',
  String path = 'news.json',
}) async {
  final bytes = await _client.storage.from(bucket).download(path);
  final jsonStr = utf8.decode(bytes);
  final dynamic data = jsonDecode(jsonStr);

  if (data is! List) return const <ArticleModel>[];

  return data
      .whereType<Map<String, dynamic>>()
      .map<ArticleModel>((m) => ArticleModel.fromMap(m))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}