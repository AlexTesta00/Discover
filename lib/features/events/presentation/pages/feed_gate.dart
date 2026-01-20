import 'package:discover/features/events/domain/entities/event_item.dart';
import 'package:discover/features/events/presentation/widgets/feed_card.dart';
import 'package:discover/features/user/domain/entities/user.dart';
import 'package:flutter/material.dart';

typedef GetEventsFeedFn = Future<List<EventItem>> Function({int limit, int offset});
typedef GetUserByEmailFn = Future<User?> Function(String email);

class FeedGate extends StatefulWidget {
  const FeedGate({
    super.key,
    required this.getEventsFeed,
    required this.getUserByEmail,
    this.pageSize = 20,
  });

  final GetEventsFeedFn getEventsFeed;
  final GetUserByEmailFn getUserByEmail;
  final int pageSize;

  @override
  State<FeedGate> createState() => _FeedGateState();
}

class _FeedGateState extends State<FeedGate> {
  final _scrollController = ScrollController();
  final _events = <EventItem>[];
  final _userFutureCache = <String, Future<User?>>{};

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;

  int get _offset => _events.length;

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _initialLoading = true;
      _error = null;
    });
    try {
      final data = await widget.getEventsFeed(limit: widget.pageSize, offset: 0);
      setState(() {
        _events
          ..clear()
          ..addAll(data);
        _hasMore = data.length >= widget.pageSize;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _initialLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    try {
      final data = await widget.getEventsFeed(limit: widget.pageSize, offset: _offset);
      setState(() {
        _events.addAll(data);
        _hasMore = data.length >= widget.pageSize;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loadingMore || !_hasMore) return;
    final threshold = 280.0;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent - pos.pixels <= threshold) _loadMore();
  }

  Future<User?> _cachedUser(String email) {
    return _userFutureCache.putIfAbsent(email, () => widget.getUserByEmail(email));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed:() {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_initialLoading) {
      return const _InitialSkeleton();
    }

    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _loadInitial,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    const Text('Qualcosa è andato storto.', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: _loadInitial, child: const Text('Riprova')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadInitial,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(child: Text('Nessuna attività')),
            SizedBox(height: 120),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _events.length + 1,
        itemBuilder: (context, i) {
          if (i == _events.length) {
            return _loadingMore
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox(height: 24);
          }
          final item = _events[i];
          return EventCard(
            item: item,
            getUserByEmail: _cachedUser,
          );
        },
      ),
    );
  }
}

class _InitialSkeleton extends StatelessWidget {
  const _InitialSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemBuilder: (_, _) => Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 160, color: Colors.black12),
                const SizedBox(height: 8),
                Container(height: 14, width: double.infinity, color: Colors.black12),
                const SizedBox(height: 8),
              ],
            ),
          )
        ],
      ),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemCount: 6,
    );
  }
}
