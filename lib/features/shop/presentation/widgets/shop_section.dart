import 'package:flutter/material.dart';
import 'package:discover/features/shop/domain/entities/shop_item.dart';
import 'shop_tile.dart';

class ShopSection extends StatelessWidget {
  const ShopSection({
    super.key,
    required this.items,
    required this.purchasedIds,
    required this.onRefresh,
    this.height,
    this.itemWidth,
  });

  final List<ShopItem> items;
  final Set<String> purchasedIds;
  final VoidCallback onRefresh;

  final double? height;

  final double? itemWidth;

  bool get _isAvatarSection =>
      items.isNotEmpty && items.first.category.name == 'avatar';

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Nessun elemento disponibile.'),
      );
    }

    final h = height ?? (_isAvatarSection ? 160.0 : 190.0);
    final w = itemWidth ?? (_isAvatarSection ? 140.0 : 220.0);

    return SizedBox(
      height: h,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final owned = purchasedIds.contains(item.id);
          return SizedBox(
            width: w,
            child: ShopTile(
              item: item,
              owned: owned,
              onRefresh: onRefresh,
            ),
          );
        },
      ),
    );
  }
}
