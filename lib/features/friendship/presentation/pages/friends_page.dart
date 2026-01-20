import 'package:discover/features/friendship/presentation/widgets/friends_appbar.dart';
import 'package:discover/features/friendship/presentation/widgets/friends_body.dart';
import 'package:discover/features/user/domain/entities/user.dart';
import 'package:discover/features/friendship/domain/entities/friend_request.dart';
import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({
    super.key,
    required this.suggestions,
    required this.friends,
    required this.incomingRequests,
    required this.isLoadingSuggestions,
    required this.isLoadingMoreSuggestions,
    required this.isLoadingIncomingRequests,
    required this.onSearchSuggestions,
    required this.onLoadMoreSuggestions,
    required this.onRefreshAll,
  });

  final List<User> suggestions;
  final List<User> friends;
  final List<FriendRequest> incomingRequests;

  final bool isLoadingSuggestions;
  final bool isLoadingMoreSuggestions;
  final bool isLoadingIncomingRequests;

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
          preferredSize: Size.fromHeight(110),
          child: FriendsAppBar(),
        ),
        body: FriendsBody(
          suggestions: suggestions,
          friends: friends,
          incomingRequests: incomingRequests,
          isLoadingSuggestions: isLoadingSuggestions,
          isLoadingMoreSuggestions: isLoadingMoreSuggestions,
          isLoadingIncomingRequests: isLoadingIncomingRequests,
          onSearchSuggestions: onSearchSuggestions,
          onLoadMoreSuggestions: onLoadMoreSuggestions,
          onRefreshAll: onRefreshAll,
        ),
      ),
    );
  }
}
