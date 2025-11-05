import 'package:discover/features/shop/domain/entities/shop_category.dart';
import 'package:discover/features/shop/domain/entities/shop_item.dart';
import 'package:discover/features/shop/domain/use_cases/shop_service.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:discover/utils/domain/use_cases/show_modal.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopTile extends StatelessWidget {
  const ShopTile({
    super.key,
    required this.item,
    required this.owned,
    required this.onRefresh,
  });

  final ShopItem item;
  final bool owned;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final repo = ShopService(Supabase.instance.client);

    return InkWell(
      borderRadius: borderRadius,
      onTap: () async {
        if (!owned) {
          // Mostra modale acquisto
          final confirmed = await _showConfirmDialog(
            context,
            title: 'Acquisto',
            message:
                'Vuoi acquistare questo oggetto per ${item.price} fenicotteri?',
            confirmText: 'Acquista',
          );
          if (confirmed == true) {
            try {
              await repo.buyItem(item.id);
              if (context.mounted) {
                await showSuccessModal(
                  context,
                  title: 'Acquisto completato!',
                  description:
                      '${item.name} è stato aggiunto al tuo inventario.',
                );
                onRefresh();
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Errore: $e')));
              }
            }
          }
        } else {
          // Mostra modale selezione
          final confirmed = await _showConfirmDialog(
            context,
            title: 'Seleziona',
            message: item.category == ShopCategory.avatar
                ? 'Vuoi selezionare questo avatar?'
                : 'Vuoi selezionare questo sfondo?',
            confirmText: 'Seleziona',
          );
          if (confirmed == true) {
            try {
              if (item.category == ShopCategory.avatar) {
                await setUserAvatar(item.asset);
                await showSuccessModal(
                  context,
                  title: "Nuovo avatar impostato 🎉",
                  description:
                      "Hai selezionato ${item.name} come tuo avatar. Controlla il profilo per vederlo!",
                );
              } else {
                await setUserBackground(item.asset);
                await showSuccessModal(
                  context,
                  title: "Nuovo sfondo impostato 🌿",
                  description:
                      "Hai selezionato ${item.name} come tuo sfondo. Controlla il profilo per vederlo!",
                );
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      item.category == ShopCategory.avatar
                          ? 'Avatar aggiornato!'
                          : 'Sfondo aggiornato!',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Errore: $e')));
              }
            }
          }
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: borderRadius,
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    color: Theme.of(context).primaryColor,
                    child: Image.asset(
                      item.asset,
                      fit: (item.category == ShopCategory.avatar)
                          ? BoxFit.contain
                          : BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (owned) Positioned(top: 8, left: 8, child: _OwnedBadge()),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.price} fenicotteri',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
}

class _OwnedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.75),
        shape: const StadiumBorder(),
      ),
      child: const Text(
        'Già acquistato',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
