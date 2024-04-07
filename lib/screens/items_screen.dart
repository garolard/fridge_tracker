import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fridge_tracker/factories/notifications_service.dart';
import 'package:fridge_tracker/models/item.dart';
import 'package:fridge_tracker/providers/items_provider.dart';
import 'package:fridge_tracker/providers/search_provider.dart';
import 'package:fridge_tracker/screens/new_item_screen.dart';
import 'package:fridge_tracker/widgets/inventory_item.dart';
import 'package:fridge_tracker/widgets/main_search_bar.dart';

final _notifications = NotificationsService();

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<ItemsScreen> {
  late Future<void> loadItemsFuture;
  var _notificationsEnabled = false;

  void _requestPermissions() async {
    final permissionsEnabled = await _notifications.requestPermission();
    setState(() {
      _notificationsEnabled = permissionsEnabled;
    });
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    loadItemsFuture = ref.read(itemsProvider.notifier).loadItems();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final items = ref.watch(itemsProvider);
    final filteredItems = ref.watch(filteredItemsProvider);

    void addNewItem() {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const NewItemScreen()));
    }

    void editItem(Item item) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => NewItemScreen(editingItem: item)));
    }

    Widget body = items.isEmpty
        ? Center(
            child: Text(
              l10n.noItemsYet,
            ),
          )
        : Column(
            children: [
              MainSearchBar(
                allItems: filteredItems,
              ),
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noItemsFound,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (ctx, index) {
                          final item = filteredItems[index];

                          // TODO: Extract this to a separate widget
                          return Dismissible(
                            key: ValueKey(item.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              ref.read(itemsProvider.notifier).removeItem(item);
                              if (_notificationsEnabled) {
                                _notifications.cancelNotification(item.notificationId);
                              }
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
                            child: InventoryItem(
                              item: item,
                              onTapped: editItem,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fridgeInventory),
        backgroundColor: theme.colorScheme.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addNewItem,
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadItemsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return body;
          }
        },
      ),
    );
  }
}
