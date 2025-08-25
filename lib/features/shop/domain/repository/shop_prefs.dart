import 'package:shared_preferences/shared_preferences.dart';
import 'package:discover/features/shop/domain/entities/shop_item_type.dart';
import 'package:discover/features/shop/domain/entities/shop_item.dart';

class ShopPrefs {
  static const _ownedBackgroundsKey = 'owned_backgrounds';
  static const _ownedAvatarsKey = 'owned_avatars';
  static const _selectedBgKey = 'selected_bg_asset';
  static const _selectedAvatarKey = 'selected_avatar_asset';
  static const defaultBackground = 'assets/images/default-bg.jpg';
  static const defaultAvatar = 'assets/images/default-avatar.jpg';

  static Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  static Future<Set<String>> getOwned(ShopItemType type) async {
    final p = await _prefs();
    final key = (type == ShopItemType.background) ? _ownedBackgroundsKey : _ownedAvatarsKey;
    final list = p.getStringList(key) ?? const <String>[];
    return list.toSet();
  }

  static Future<void> _saveOwned(ShopItemType type, Set<String> owned) async {
    final p = await _prefs();
    final key = (type == ShopItemType.background) ? _ownedBackgroundsKey : _ownedAvatarsKey;
    await p.setStringList(key, owned.toList());
  }

  static Future<bool> isOwned(ShopItem item) async {
    final owned = await getOwned(item.type);
    return owned.contains(item.asset);
  }

  static Future<void> addOwned(ShopItem item) async {
    final owned = await getOwned(item.type);
    owned.add(item.asset);
    await _saveOwned(item.type, owned);
  }

  static Future<void> setSelected(ShopItem item) async {
    final p = await _prefs();
    if (item.type == ShopItemType.background) {
      await p.setString(_selectedBgKey, item.asset);
    } else {
      await p.setString(_selectedAvatarKey, item.asset);
    }
  }

  static Future<void> setBackground(String asset) async {
    final p = await _prefs();
    await p.setString(_selectedBgKey, asset);
  }

  static Future<void> setAvatar(String asset) async {
    final p = await _prefs();
    await p.setString(_selectedAvatarKey, asset);
  }

  static Future<String> getBackground() async {
    final p = await _prefs();
    return p.getString(_selectedBgKey) ?? defaultBackground;
    }

  static Future<String> getAvatar() async {
    final p = await _prefs();
    return p.getString(_selectedAvatarKey) ?? defaultAvatar;
  }
}
