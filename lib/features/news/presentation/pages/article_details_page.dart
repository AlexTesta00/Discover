import 'package:discover/features/news/domain/entities/article.dart';
import 'package:flutter/material.dart';

class ArticleDetailsPage extends StatelessWidget {

  final Article article;

  const ArticleDetailsPage({super.key, required this.article});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              article.image != ''
                  ? Image.network(
                      article.image,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 100),
                    ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  article.title ?? "Nessun titolo",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              if (article.description != '')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    article.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}