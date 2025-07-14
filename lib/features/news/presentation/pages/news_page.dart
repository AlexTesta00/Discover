import 'package:discover/features/news/data/sources/article_remote_sources.dart';
import 'package:discover/features/news/presentation/pages/article_details_page.dart';
import 'package:discover/features/news/presentation/widgets/article_card.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: loadArticleFromDatabase(), 
        builder: (context, snapshot) {
          //Loading..
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator());
          }

          //Error
          if(snapshot.hasError){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${snapshot.error}')));
          }

          if(snapshot.data!.isEmpty){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Dati non presenti")));
          }
    
          //Loaded
          final articles = snapshot.data!;
    
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
    
              //Article Card UI
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
                    )
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}