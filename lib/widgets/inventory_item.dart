import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_tracker/factories/notifications_service.dart';
import 'package:fridge_tracker/models/item.dart';
import 'package:fridge_tracker/providers/items_provider.dart';
import 'package:fridge_tracker/screens/new_item_screen.dart';

final _notifications = NotificationsService();

class InventoryItem extends ConsumerWidget {
  const InventoryItem({
    super.key,
    required this.item,
    required this.notificationsEnabled,
  });

  final Item item;
  final bool notificationsEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    void editItem(Item item) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => NewItemScreen(editingItem: item)));
    }

    final itemSubtitleTextStyle = theme.textTheme.bodyMedium!
        .copyWith(color: item.isExpired ? theme.colorScheme.error : theme.colorScheme.onSurface);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(itemsProvider.notifier).removeItem(item);
        if (notificationsEnabled) {
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
      child: ListTile(
        onTap: () => editItem(item),
        title: Text(
          item.title,
          style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          !item.isExpired
              ? l10n.expiryInDays(item.expiryDate.difference(DateTime.now()).inDays + 1)
              : l10n.expired,
          style: itemSubtitleTextStyle,
        ),
        trailing: item.image != null
            ? Hero(
                tag: item.image!,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 114,
                    height: 64,
                    child: Image.file(
                      item.image!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
