import 'package:discover/features/shop/domain/entities/shop_item_type.dart';
import 'package:flutter/foundation.dart';

@immutable
class ShopItem {
  final String title;
  final String asset;
  final int cost;
  final ShopItemType type;

  const ShopItem({
    required this.title,
    required this.asset,
    required this.cost,
    required this.type,
  });

  factory ShopItem.fromJson(Map<String, dynamic> json, ShopItemType type) {
    return ShopItem(
      title: json['title'] as String,
      asset: json['asset'] as String,
      cost: json['cost'] as int,
      type: type,
    );
  }
}