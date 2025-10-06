import 'package:supabase_flutter/supabase_flutter.dart';

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

Future<Map<String, dynamic>?> getMyLevel() async {
  final uid = _supabase.auth.currentUser?.id;
  if (uid == null) return null;

  final res = await _supabase
      .from('user_profiles')
      .select('level_grade, level:levels(name, xp_to_reach)')
      .eq('user_id', uid)
      .maybeSingle();
  return res;
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



Future<void> addXpAndBalance({int xp = 0, int balance = 0}) async {
  final user = _supabase.auth.currentUser;
  if (user == null) throw const AuthException('Non autenticato');

  await _supabase.rpc('increment_profile_stats', params: {
    'p_user_id': user.id,
    'p_xp': xp,
    'p_balance': balance,
  });
}