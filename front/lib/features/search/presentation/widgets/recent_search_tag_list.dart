import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/recent_search_provider.dart';
import 'recent_search_tag.dart';

class RecentSearchTagList extends ConsumerWidget {
  final List<String> items;
  final void Function(String value)? onTapItem;

  const RecentSearchTagList({
    super.key,
    required this.items,
    this.onTapItem,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 32, // 태그 높이(24) + 여유
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 좌측 여백 0, 태그 간격 10
            for (int i = 0; i < items.length; i++) ...[
              RecentSearchTag(
                label: items[i],
                onTap: () => onTapItem?.call(items[i]),
                onDelete: () => ref.read(recentSearchProvider.notifier).remove(items[i]),
              ),
              if (i != items.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      ),
    );
  }
}




