import 'package:flutter/material.dart';
import 'package:fridge_tracker/models/item.dart';

class MainSearchBar extends StatelessWidget {
  const MainSearchBar({super.key, required this.allItems});

  final List<Item> allItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SearchAnchor(builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
          ),
          child: TextField(
            controller: controller,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Search for something...',
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
              hintStyle: theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      }, suggestionsBuilder: (context, controller) {
        return List.generate(allItems.length, (index) => Text(allItems[index].title));
      }),
    );
  }
}
