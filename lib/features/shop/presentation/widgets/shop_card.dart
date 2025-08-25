import 'package:flutter/material.dart';
import 'package:discover/features/shop/domain/entities/shop_item.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({
    super.key,
    required this.item,
    this.onTap,
    this.owned = false,
  });

  final ShopItem item;
  final VoidCallback? onTap;
  final bool owned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    item.asset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceVariant,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                  if (owned)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Acquistato',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.whatshot, size: 16, color: Colors.redAccent),
              const SizedBox(width: 6),
              Text(
                item.cost.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}