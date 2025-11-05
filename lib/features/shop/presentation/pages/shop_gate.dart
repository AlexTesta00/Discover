import 'package:discover/features/shop/domain/repository/shop_data.dart';
import 'package:discover/features/shop/domain/use_cases/shop_service.dart';
import 'package:discover/features/shop/presentation/widgets/shop_section.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
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
    int balance = 0;
    if (me != null) {
      final row = await Supabase.instance.client
          .from('user_profiles')
          .select('balance')
          .eq('email', getUserEmail()!)
          .maybeSingle();
      balance = (row?['balance'] as num?)?.toInt() ?? 0;
    }

    return ShopData(
      avatars: avatars,
      backgrounds: backgrounds,
      purchasedIds: purchasedIds,
      balance: balance,
    );
  }

  Future<void> _refresh() async {
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Avatar',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ShopSection(
                      items: data.avatars,
                      purchasedIds: data.purchasedIds,
                      onRefresh: _refresh,
                      height: 160,
                      itemWidth: 140,
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Sfondi',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ShopSection(
                      items: data.backgrounds,
                      purchasedIds: data.purchasedIds,
                      onRefresh: _refresh,
                      height: 180,
                      itemWidth: 220,
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Saldo: ${data.balance} fenicotteri',
                textAlign: TextAlign.right,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      },
    );
  }
}
