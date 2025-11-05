import 'package:discover/features/shop/domain/entities/shop_item.dart';

class ShopData {
  final List<ShopItem> avatars;
  final List<ShopItem> backgrounds;
  final Set<String> purchasedIds;
  final int balance;
  ShopData({
    required this.avatars,
    required this.backgrounds,
    required this.purchasedIds,
    required this.balance,
  });
}
