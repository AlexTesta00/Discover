import 'package:discover/features/events/domain/entities/event_item.dart';
import 'package:discover/features/events/presentation/widgets/feed_card.dart';
import 'package:discover/features/user/domain/entities/user.dart';
import 'package:flutter/material.dart';

class EventsFeedPage extends StatefulWidget {
  const EventsFeedPage({
    super.key,
    required this.events,
    required this.getUserByEmail,
  });

  final List<EventItem> events;
  final Future<User?> Function(String email) getUserByEmail;

  @override
  State<EventsFeedPage> createState() => _EventsFeedPageState();
}

class _EventsFeedPageState extends State<EventsFeedPage> {
  final Map<String, Future<User?>> _userFutureCache = {};

  Future<User?> _cachedFetch(String email) {
    return _userFutureCache.putIfAbsent(email, () => widget.getUserByEmail(email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: widget.events.length,
        separatorBuilder: (_, __) => const SizedBox.shrink(),
        itemBuilder: (_, i) {
          final item = widget.events[i];
          return EventCard(
            item: item,
            getUserByEmail: _cachedFetch,
          );
        },
      ),
    );
  }
}
