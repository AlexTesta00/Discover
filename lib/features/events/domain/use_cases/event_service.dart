import 'package:discover/features/events/domain/entities/event_item.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final SupabaseClient _supabase = Supabase.instance.client;

Future<String> addEvent(String description) async {
  final res = await _supabase.rpc('add_event', params: {
    'p_description': description,
  });
  if (res is String) return res;
  return res?.toString() ?? '';
}

Future<List<EventItem>> getEventsFeed({int limit = 50, int offset = 0}) async {
  final res = await _supabase.rpc('get_events_feed', params: {
    'p_limit': limit,
    'p_offset': offset,
  });

  if (res is List) {
    return res
        .cast<Map<String, dynamic>>()
        .map(EventItem.fromMap)
        .toList();
  }
  return const [];
}
