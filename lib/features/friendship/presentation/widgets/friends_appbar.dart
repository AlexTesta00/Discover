import 'package:flutter/material.dart';

class FriendsAppBar extends StatelessWidget {
  const FriendsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      bottom: false,
      child: Container(
        color: const Color(0xFFF9F7F3),
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
            const Spacer(),
            TabBar(
              labelColor: primary,
              unselectedLabelColor: const Color(0xFF1B1B1B),
              indicatorColor: primary,
              indicatorWeight: 2,
              dividerColor: Colors.transparent,
              labelStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Invita Amici'),
                Tab(text: 'Amicizie'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}