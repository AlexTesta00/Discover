import 'package:discover/features/maps/domain/entities/point_of_interest.dart';
import 'package:flutter/material.dart';

class PointOfInterestDetails extends StatelessWidget {
  final PointOfInterest point;

  const PointOfInterestDetails({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            point.imageUrl != null
                ? Image.network(
                    point.imageUrl!,
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
                point.title ?? "Senza titolo",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            if (point.description != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  point.description!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}