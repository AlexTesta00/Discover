import 'package:discover/features/shop/domain/entities/shop_category.dart';

class ShopItem {
  final String id;
  final String name;
  final int price;
  final String asset;
  final ShopCategory category;

  ShopItem({
    required this.id,
    required this.name,
    required this.price,
    required this.asset,
    required this.category,
  });

  factory ShopItem.fromMap(Map<String, dynamic> m) => ShopItem(
        id: m['id'] as String,
        name: m['name'] as String,
        price: (m['price'] as num).toInt(),
        asset: m['asset'] as String,
        category: shopCategoryFromString(m['category'] as String),
      );
}