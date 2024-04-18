import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fridge_tracker/models/item.dart';

class InventoryItem extends StatelessWidget {
  const InventoryItem({
    super.key,
    required this.item,
    required this.onTapped,
  });

  final Item item;
  final void Function(Item) onTapped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final itemSubtitleTextStyle = theme.textTheme.bodyMedium!
        .copyWith(color: item.isExpired ? theme.colorScheme.error : theme.colorScheme.onSurface);

    return ListTile(
      onTap: () => onTapped(item),
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
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 114,
                height: 64,
                child: Image.file(
                  item.image!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : null,
    );
  }
}
