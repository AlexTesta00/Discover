import 'package:discover/features/gamification/domain/entities/level.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../entities/user.dart';

final SupabaseClient _supabase = Supabase.instance.client;
const String _profilesTable = 'user_profiles';
const String _defaultAvatar = 'assets/avatar/avatar_9.png';
const String _defaultBackground = 'assets/background/default.png';

Future<String?> getUserAvatar() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final res = await _supabase
      .from(_profilesTable)
      .select('avatar_url')
      .eq('user_id', user.id)
      .maybeSingle();
  return (res?['avatar_url'] as String?) ?? _defaultAvatar;
}

Future<String?> getUserBackground() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final res = await _supabase
      .from(_profilesTable)
      .select('background_url')
      .eq('user_id', user.id)
      .maybeSingle();

  return (res?['background_url'] as String?) ?? _defaultBackground;
}

String? getUserEmail() {
  final session = _supabase.auth.currentSession;
  return session?.user.email;
}

Future<int?> getUserXp() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final res = await _supabase
      .from(_profilesTable)
      .select('xp')
      .eq('user_id', user.id)
      .maybeSingle();

  return res?['xp'] as int?;
}

Future<int?> getUserBalance() async {
  final user = _supabase.auth.currentUser;
  if (user == null) return null;

  final res = await _supabase
      .from(_profilesTable)
      .select('balance')
      .eq('user_id', user.id)
      .maybeSingle();

  return res?['balance'] as int?;
}

Future<Level?> getMyLevel() async {
  final uid = _supabase.auth.currentUser?.id;
  if (uid == null) return null;

  final res = await _supabase
      .from('user_profiles')
      .select('level_grade, level:levels(grade, name, xp_to_reach)')
      .eq('user_id', uid)
      .maybeSingle();

  if (res == null) return null;

  final levelData = res['level'] as Map<String, dynamic>?;

  if (levelData == null) {
    return Level(grade: 0, name: 'Sconosciuto', xpToReach: 0);
  }

  return Level.fromJson(levelData);
}

Future<int?> getXpToNextLevelGap() async {
  final uid = _supabase.auth.currentUser?.id;
  if (uid == null) return null;

  final row = await _supabase
      .from('user_profiles')
      .select('xp, level_grade, next:levels!inner(grade, xp_to_reach)')
      .eq('user_id', uid)
      .maybeSingle();

  final xp = row?['xp'] as int? ?? 0;
  final currentGrade = row?['level_grade'] as int? ?? 1;

  final nextLevel = await _supabase
      .from('levels')
      .select('xp_to_reach')
      .gt('grade', currentGrade)
      .order('grade', ascending: true)
      .limit(1)
      .maybeSingle();

  final nextXp = nextLevel?['xp_to_reach'] as int?;
  if (nextXp == null) return 0;
  return (nextXp - xp).clamp(0, 1 << 31);
}

Future<Level?> getNextLevel() async {
  final uid = _supabase.auth.currentUser?.id;
  if (uid == null) return null;

  final res = await _supabase.rpc('get_next_level', params: {'p_user_id': uid});

  if (res == null) return null;
  if (res is List && res.isNotEmpty) {
    final row = res.first as Map<String, dynamic>;
    return Level.fromJson(row);
  }

  return null;
}

Future<void> addXpAndBalance({int xp = 0, int balance = 0}) async {
  final user = _supabase.auth.currentUser;
  if (user == null) throw const AuthException('Non autenticato');

  await _supabase.rpc(
    'increment_profile_stats',
    params: {'p_user_id': user.id, 'p_xp': xp, 'p_balance': balance},
  );
}

Future<void> addFriend(String friendEmail) async {
  await _supabase.rpc(
    'add_friend_by_email',
    params: {'p_other_email': friendEmail},
  );
}

Future<void> removeFriend(String friendEmail) async {
  await _supabase.rpc(
    'remove_friend_by_email',
    params: {'p_other_email': friendEmail},
  );
}

Future<User?> getUserByEmail(String email) async {
  final res = await _supabase.rpc(
    'get_user_by_email',
    params: {'p_email': email},
  );
  if (res is List && res.isNotEmpty) {
    return User.fromRpcRow(res.first as Map<String, dynamic>);
  }
  return null;
}

Future<List<User>> getNonFriends({
  String? search,
  int limit = 20,
  int offset = 0,
}) async {
  final res = await _supabase.rpc(
    'get_non_friends',
    params: {'p_search': search, 'p_limit': limit, 'p_offset': offset},
  );

  if (res is List) {
    return res.cast<Map<String, dynamic>>().map(User.fromRpcRow).toList();
  }
  return const [];
}

Future<List<User>> getMyFriends({
  String? search,
  int limit = 50,
  int offset = 0,
}) async {
  final res = await _supabase.rpc(
    'get_my_friends',
    params: {'p_search': search, 'p_limit': limit, 'p_offset': offset},
  );

  if (res is List) {
    return res.cast<Map<String, dynamic>>().map(User.fromRpcRow).toList();
  }
  return const [];
}

Future<int> getFriendsCount({String? email}) async {
  final res = await _supabase.rpc(
    'get_friends_count',
    params: {'p_email': email},
  );

  if (res == null) return 0;
  if (res is int) return res;
  if (res is num) return res.toInt();
  return int.tryParse(res.toString()) ?? 0;
}

Future<int> getFriendsCountByEmail(String email) async {
  final res = await _supabase.rpc('get_friends_count_by_email', params: {
    'p_email': email,
  });

  if (res == null) return 0;
  if (res is int) return res;
  if (res is num) return res.toInt();
  return int.tryParse(res.toString()) ?? 0;
}

Future<void> setUserAvatar(String assetPath) async {
  await _supabase.rpc('set_user_avatar', params: {'p_asset': assetPath});
}
Future<void> setUserBackground(String assetPath) async {
  await _supabase.rpc('set_user_background', params: {'p_asset': assetPath});
}