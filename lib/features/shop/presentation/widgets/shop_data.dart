import 'package:discover/features/shop/domain/entities/shop_item.dart';

class ShopData {
  const ShopData({required this.backgrounds, required this.avatars});
  final List<ShopItem> backgrounds;
  final List<ShopItem> avatars;
}
