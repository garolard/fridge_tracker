import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_tracker/providers/items_provider.dart';
import 'package:fridge_tracker/providers/search_provider.dart';
import 'package:fridge_tracker/screens/new_item_screen.dart';
import 'package:fridge_tracker/widgets/inventory_item.dart';
import 'package:fridge_tracker/widgets/main_search_bar.dart';

class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  late Future<void> loadItemsFuture;

  @override
  void initState() {
    super.initState();
    loadItemsFuture = ref.read(itemsProvider.notifier).loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ref.watch(filteredItemsProvider);

    Widget body = items.isEmpty
        ? const Center(
            child: Text(
              'No items yet...',
            ),
          )
        : Column(
            children: [
              MainSearchBar(
                allItems: items,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, index) {
                    final item = items[index];

                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        ref.read(itemsProvider.notifier).removeItem(item);
                      },
                      background: Container(
                        color: theme.colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      child: InventoryItem(item: item),
                    );
                  },
                ),
              ),
            ],
          );

    void addNewItem() {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const NewItemScreen()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fridge Inventory'),
        backgroundColor: theme.colorScheme.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addNewItem,
          ),
        ],
      ),
      body: body,
    );
  }
}
