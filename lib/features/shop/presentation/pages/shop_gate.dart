import 'package:discover/features/shop/domain/repository/shop_data.dart';
import 'package:discover/features/shop/domain/use_cases/shop_service.dart';
import 'package:discover/features/shop/presentation/widgets/shop_tile.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:discover/features/user/presentation/widgets/balance_notifier.dart';
import 'package:discover/utils/presentation/pages/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopGate extends StatefulWidget {
  const ShopGate({super.key});

  @override
  State<ShopGate> createState() => _ShopGateState();
}

class _ShopGateState extends State<ShopGate> {
  late final ShopService repo = ShopService(Supabase.instance.client);

  late Future<ShopData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadAll();
  }

  Future<ShopData> _loadAll() async {
    final avatars = await repo.getAvatars();
    final backgrounds = await repo.getBackgrounds();
    final purchased = await repo.getMyPurchasedItems();
    final purchasedIds = purchased.map((e) => e.id).toSet();

    final me = Supabase.instance.client.auth.currentUser;
    if (me != null) {
      await Supabase.instance.client
          .from('user_profiles')
          .select('balance')
          .eq('email', getUserEmail()!)
          .maybeSingle();
    }

    return ShopData(
      avatars: avatars,
      backgrounds: backgrounds,
      purchasedIds: purchasedIds,
    );
  }

  Future<void> _refresh() async {
    await BalanceNotifier.I.refresh();
    setState(() {
      _future = _loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ShopData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingPage());
        }
        if (snap.hasError) {
          return Scaffold(body: Center(child: Text('Errore: ${snap.error}')));
        }
        final data = snap.data!;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85, // unico valore per tutti
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final allItems = [
                            ...data.avatars,
                            ...data.backgrounds,
                          ];

                          final item = allItems[index];
                          final owned = data.purchasedIds.contains(item.id);

                          return ShopTile(
                            item: item,
                            owned: owned,
                            onRefresh: _refresh,
                          );
                        },
                        childCount:
                            data.avatars.length + data.backgrounds.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
