import 'package:flutter/material.dart';
import 'package:discover/features/shop/domain/entities/shop_item.dart';
import 'package:discover/features/shop/presentation/widgets/shop_card.dart';

class ShopSection extends StatelessWidget {
  const ShopSection({
    super.key,
    required this.title,
    required this.items,
    this.onTap,
  });

  final String title;
  final List<ShopItem> items;
  final void Function(ShopItem item)? onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final double horizontalPadding = w >= 600 ? 24 : 16;
    final double cardWidth = w >= 900 ? 220 : (w >= 600 ? 200 : 170);
    final double listHeight = cardWidth + 58;

    return SliverList.list(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 8),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: cardWidth,
                child: ShopCard(
                  item: item,
                  onTap: () => onTap?.call(item),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
