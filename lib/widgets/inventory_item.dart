import 'package:flutter/material.dart';
import 'package:fridge_tracker/models/item.dart';

class InventoryItem extends StatelessWidget {
  const InventoryItem({
    super.key,
    required this.item,
  });

  final Item item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(
        item.title,
        style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'expiry in ${item.expiryDate!.difference(DateTime.now()).inDays} days',
        style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface),
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
