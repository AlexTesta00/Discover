import 'package:discover/features/friendship/presentation/widgets/friends_appbar.dart';
import 'package:discover/features/friendship/presentation/widgets/friends_body.dart';
import 'package:discover/features/user/domain/entity/user.dart';
import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({
    super.key,
    required this.suggestions,
    required this.friends,
    required this.isLoadingSuggestions,
    required this.onSearchSuggestions,
    required this.onLoadMoreSuggestions,
    required this.isLoadingMoreSuggestions,
    required this.onRefreshAll,
  });

  final List<User> suggestions;
  final List<User> friends;

  final bool isLoadingSuggestions;
  final bool isLoadingMoreSuggestions;

  final ValueChanged<String> onSearchSuggestions;
  final Future<void> Function() onRefreshAll;
  final Future<void> Function() onLoadMoreSuggestions;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9F7F3);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: FriendsAppBar(),
        ),
        body: FriendsBody(
          suggestions: suggestions,
          friends: friends,
          isLoadingSuggestions: isLoadingSuggestions,
          isLoadingMoreSuggestions: isLoadingMoreSuggestions,
          onSearchSuggestions: onSearchSuggestions,
          onLoadMoreSuggestions: onLoadMoreSuggestions,
          onRefreshAll: onRefreshAll,
        ),
      ),
    );
  }
}
