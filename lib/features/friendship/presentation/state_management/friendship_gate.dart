import 'dart:async';
import 'package:discover/features/user/domain/entity/user.dart';
import 'package:discover/features/user/domain/use_cases/user_service.dart';
import 'package:flutter/material.dart';
import 'package:discover/features/friendship/presentation/pages/friends_page.dart';

class FriendshipGate extends StatefulWidget {
  const FriendshipGate({super.key});

  @override
  State<FriendshipGate> createState() => _FriendshipGateState();
}

class _FriendshipGateState extends State<FriendshipGate> {
  final int _sugPageSize = 20;
  bool _sugIsLoading = false;
  bool _sugIsLoadingMore = false;
  bool _sugHasMore = true;
  String? _sugSearch;
  int _sugOffset = 0;
  final List<User> _suggestions = [];

  final int _friendsPageSize = 50;
  bool _friendsIsLoading = false;
  bool _friendsHasMore = true;
  String? _friendsSearch;
  int _friendsOffset = 0;
  final List<User> _friends = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadAllFirstPages();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAllFirstPages() async {
    await Future.wait([
      _loadSuggestionsFirstPage(),
      _loadFriendsFirstPage(),
    ]);
  }

  Future<void> _onRefreshAll() async {
    await _loadAllFirstPages();
  }

  Future<void> _loadSuggestionsFirstPage() async {
    setState(() {
      _sugIsLoading = true;
      _sugOffset = 0;
      _sugHasMore = true;
      _suggestions.clear();
    });
    try {
      final rows = await getNonFriends(
        search: _sugSearch,
        limit: _sugPageSize,
        offset: _sugOffset,
      );
      if (!mounted) return;
      setState(() {
        _suggestions.addAll(rows);
        _sugHasMore = rows.length == _sugPageSize;
        _sugOffset = rows.length;
      });
    } catch (_) {
      // TODO: tech debit: handle error
    } finally {
      if (mounted) setState(() => _sugIsLoading = false);
    }
  }

  Future<void> _loadMoreSuggestions() async {
    if (_sugIsLoadingMore || !_sugHasMore) return;
    setState(() => _sugIsLoadingMore = true);
    try {
      final rows = await getNonFriends(
        search: _sugSearch,
        limit: _sugPageSize,
        offset: _sugOffset,
      );
      if (!mounted) return;
      setState(() {
        _suggestions.addAll(rows);
        _sugHasMore = rows.length == _sugPageSize;
        _sugOffset += rows.length;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _sugIsLoadingMore = false);
    }
  }

  void _onSuggestionsSearchChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _sugSearch = q.isEmpty ? null : q;
      _loadSuggestionsFirstPage();
    });
  }

  Future<void> _loadFriendsFirstPage() async {
    setState(() {
      _friendsIsLoading = true;
      _friendsOffset = 0;
      _friendsHasMore = true;
      _friends.clear();
    });
    try {
      final rows = await getMyFriends(
        search: _friendsSearch,
        limit: _friendsPageSize,
        offset: _friendsOffset,
      );
      if (!mounted) return;
      setState(() {
        _friends.addAll(rows);
        _friendsHasMore = rows.length == _friendsPageSize;
        _friendsOffset = rows.length;
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _friendsIsLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return FriendsPage(
      suggestions: _suggestions,
      isLoadingSuggestions: _sugIsLoading,
      isLoadingMoreSuggestions: _sugIsLoadingMore,
      onSearchSuggestions: _onSuggestionsSearchChanged,
      onLoadMoreSuggestions: _loadMoreSuggestions,
      friends: _friends,
      onRefreshAll: _onRefreshAll,
    );
  }
}
