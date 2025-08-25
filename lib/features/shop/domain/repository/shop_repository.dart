import 'dart:convert';

import 'package:discover/features/shop/domain/entities/shop_item.dart';
import 'package:discover/features/shop/domain/entities/shop_item_type.dart';
import 'package:flutter/services.dart';

class ShopRepository {
  const ShopRepository();

  Future<List<ShopItem>> loadBackgrounds() async {
    final raw = await rootBundle.loadString('assets/data/background.json');
    final items = jsonDecode(raw) as List;
    return items.map((e) => ShopItem.fromJson(e, ShopItemType.background)).toList();
  }

  Future<List<ShopItem>> loadAvatars() async {
    final raw = await rootBundle.loadString('assets/data/avatar.json');
    final items = jsonDecode(raw) as List;
    return items.map((e) => ShopItem.fromJson(e, ShopItemType.avatar)).toList();
  }
}