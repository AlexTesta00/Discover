import 'package:discover/features/news/data/models/article_model.dart';
import 'package:discover/features/news/data/sources/article_remote_sources.dart';
import 'package:discover/features/news/presentation/pages/article_details_page.dart';
import 'package:discover/features/news/presentation/widgets/article_card.dart';
import 'package:discover/features/news/presentation/widgets/skeleton_loading_news.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late Future<List<ArticleModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchArticlesFromBucket();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = fetchArticlesFromBucket();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<ArticleModel>>(
          future: _future,
          builder: (context, snapshot) {
            // Loading
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const SkeletonLoadingNews();
            }

            // Error
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline),
                        const SizedBox(height: 8),
                        Text('Si è verificato un errore:\n${snapshot.error}'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _refresh,
                          child: const Text('Riprova'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final articles = snapshot.data ?? const <ArticleModel>[];

            // Empty state
            if (articles.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.article_outlined),
                        SizedBox(height: 8),
                        Text('Nessuna news disponibile al momento.'),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Loaded
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index]; // ArticleModel estende Article
                return ArticleCard(
                  title: article.title,
                  imageUrl: article.image,
                  date: article.date,
                  description: article.description,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailsPage(article: article),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}