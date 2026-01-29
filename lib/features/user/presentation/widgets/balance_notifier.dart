import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';

class BalanceNotifier {
  BalanceNotifier._();
  static final BalanceNotifier I = BalanceNotifier._();

  final ValueNotifier<int> balance = ValueNotifier<int>(0);

  Future<void> refresh() async {
    final me = Supabase.instance.client.auth.currentUser;
    if (me == null) {
      balance.value = 0;
      return;
    }

    final row = await Supabase.instance.client
        .from('user_profiles')
        .select('balance')
        .eq('email', getUserEmail()!)
        .maybeSingle();

    balance.value = (row?['balance'] as num?)?.toInt() ?? 0;
  }
}
