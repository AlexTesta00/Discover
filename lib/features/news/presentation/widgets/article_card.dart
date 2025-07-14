import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArticleCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final DateTime date;
  final String description;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.description,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMMM yyyy', 'it_IT').format(date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(20, 0, 0, 0),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
      
            const SizedBox(width: 12),
      
            // Image
            Hero(
              tag: imageUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
