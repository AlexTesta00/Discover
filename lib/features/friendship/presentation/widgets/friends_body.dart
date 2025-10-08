import 'package:discover/features/friendship/presentation/widgets/friendship_tab.dart';
import 'package:discover/features/friendship/presentation/widgets/invite_friends_tab.dart';
import 'package:discover/features/user/domain/entity/user.dart';
import 'package:flutter/material.dart';

class FriendsBody extends StatelessWidget {
  const FriendsBody({
    super.key,
    required this.suggestions,
    required this.friends,
    required this.isLoadingSuggestions,
    required this.isLoadingMoreSuggestions,
    required this.onSearchSuggestions,
    required this.onLoadMoreSuggestions,
    required this.onRefreshAll,
  });

  final List<User> suggestions;
  final List<User> friends;
  final bool isLoadingSuggestions;
  final bool isLoadingMoreSuggestions;
  final ValueChanged<String> onSearchSuggestions;
  final Future<void> Function() onLoadMoreSuggestions;
  final Future<void> Function() onRefreshAll;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        InviteFriendsTab(
          suggestions: suggestions,
          isLoading: isLoadingSuggestions,
          isLoadingMore: isLoadingMoreSuggestions,
          onSearch: onSearchSuggestions,
          onLoadMore: onLoadMoreSuggestions,
          onRefresh: onRefreshAll,
        ),
        FriendshipsTab(
          friends: friends,
          onRefresh: onRefreshAll,
        ),
      ],
    );
  }
}
