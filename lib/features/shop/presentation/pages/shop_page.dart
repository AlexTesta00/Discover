import 'package:discover/features/shop/domain/repository/shop_repository.dart';
import 'package:discover/features/shop/presentation/widgets/shop_data.dart';
import 'package:flutter/material.dart';
import 'package:discover/features/shop/domain/entities/shop_item.dart';
import 'package:discover/features/shop/presentation/widgets/shop_error.dart';
import 'package:discover/features/shop/presentation/widgets/shop_loading.dart';
import 'package:discover/features/shop/presentation/widgets/shop_section.dart'; // <— nuovo import

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, this.onTapItem});

  final void Function(ShopItem item)? onTapItem;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final _repo = const ShopRepository();
  Future<ShopData>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<ShopData> _load() async {
    final result = await Future.wait([
      _repo.loadBackgrounds(),
      _repo.loadAvatars(),
    ]);
    return ShopData(backgrounds: result[0], avatars: result[1]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ShopData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _future == null) {
            return const ShopLoading();
          }
          if (snapshot.hasError) {
            return ShopError(
              message: 'Errore: ${snapshot.error}',
              onRetry: _reload,
            );
          }

          final data = snapshot.requireData;

          return CustomScrollView(
            slivers: [
              ShopSection(
                title: 'Sfondi',
                items: data.backgrounds,
                onTap: widget.onTapItem,
              ),
              ShopSection(
                title: 'Avatar',
                items: data.avatars,
                onTap: widget.onTapItem,
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          );
        },
      ),
    );
  }
}
