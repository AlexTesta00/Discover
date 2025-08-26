import 'package:shared_preferences/shared_preferences.dart';

class CompletedStore {
  static const _prefix = 'challenge_done_';

  Future<bool> isDone(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$id') ?? false;
    }

  Future<void> toggle(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool('$_prefix$id') ?? false;
    await prefs.setBool('$_prefix$id', !current);
  }

  Future<void> setDone(String id, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$id', value);
  }
}