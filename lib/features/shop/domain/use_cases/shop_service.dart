import 'package:discover/features/shop/domain/entities/shop_category.dart';
import 'package:discover/features/shop/domain/entities/shop_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopService {
  ShopService(this._sb);
  final SupabaseClient _sb;

  /// Tutti gli item dello shop
  Future<List<ShopItem>> getAll() async {
    final res = await _sb
        .from('shop_items')
        .select('id,name,price,asset,category')
        .order('created_at', ascending: false);
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(ShopItem.fromMap).toList();
  }

  /// Solo avatar
  Future<List<ShopItem>> getAvatars() async {
    final res = await _sb
        .from('shop_items')
        .select('id,name,price,asset,category')
        .eq('category', 'avatar')
        .order('created_at', ascending: false);
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(ShopItem.fromMap).toList();
  }

  /// Solo sfondi
  Future<List<ShopItem>> getBackgrounds() async {
    final res = await _sb
        .from('shop_items')
        .select('id,name,price,asset,category')
        .eq('category', 'background')
        .order('created_at', ascending: false);
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(ShopItem.fromMap).toList();
  }

  /// Acquista (RPC con check saldo + update atomico)
  Future<void> buyItem(String itemId) async {
    await _sb.rpc('buy_shop_item', params: {'p_item_id': itemId});
  }

  /// Tutti i prodotti acquistati dall'utente corrente
  Future<List<ShopItem>> getMyPurchasedItems() async {
    final res = await _sb.rpc('get_my_shop_items');
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows.map(ShopItem.fromMap).toList();
  }

  /// I miei avatar acquistati
  Future<List<ShopItem>> getMyPurchasedAvatars() async {
    final res = await _sb.rpc('get_my_shop_items');
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows
        .map(ShopItem.fromMap)
        .where((i) => i.category == ShopCategory.avatar)
        .toList();
  }

  /// I miei sfondi acquistati
  Future<List<ShopItem>> getMyPurchasedBackgrounds() async {
    final res = await _sb.rpc('get_my_shop_items');
    final rows = (res as List).cast<Map<String, dynamic>>();
    return rows
        .map(ShopItem.fromMap)
        .where((i) => i.category == ShopCategory.background)
        .toList();
  }
}