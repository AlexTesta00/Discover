import 'package:flutter/material.dart';

class ShopLoading extends StatelessWidget {
  const ShopLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
