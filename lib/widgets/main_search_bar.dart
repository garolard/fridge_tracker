import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_tracker/models/item.dart';
import 'package:fridge_tracker/providers/search_provider.dart';

class MainSearchBar extends ConsumerStatefulWidget {
  const MainSearchBar({super.key, required this.allItems});

  final List<Item> allItems;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainSearchBarState();
}

class _MainSearchBarState extends ConsumerState<MainSearchBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface,
        ),
        child: TextField(
          controller: _searchController,
          textAlignVertical: TextAlignVertical.center,
          style: theme.textTheme.bodyMedium!.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Search for something...',
            prefixIcon: const Icon(Icons.search),
            border: InputBorder.none,
            hintStyle: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          onChanged: (value) => ref.read(searchProvider.notifier).updateSearch(value),
        ),
      ),
    );
  }
}
