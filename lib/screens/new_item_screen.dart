import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_tracker/models/item.dart';
import 'package:fridge_tracker/providers/items_provider.dart';
import 'package:fridge_tracker/widgets/item_image_picker.dart';

class NewItemScreen extends ConsumerStatefulWidget {
  const NewItemScreen({super.key, this.editingItem});

  final Item? editingItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends ConsumerState<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isEditing = false;
  File? _pickedImage;
  var _pickedName = '';
  var _pickedDaysUntilExpiry = 0;

  @override
  void initState() {
    super.initState();
    if (widget.editingItem != null) {
      _pickedName = widget.editingItem!.title;
      _pickedImage = widget.editingItem!.image;
      _isEditing = true;
    }
  }

  void onImagePicked(File? pickedImage) {
    _pickedImage = pickedImage;
  }

  void saveItem() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    final items = ref.read(itemsProvider.notifier);
    final newItem = Item(
      title: _pickedName,
      daysUntilExpiry: _pickedDaysUntilExpiry,
      image: _pickedImage,
    );
    items.addItem(newItem);

    Navigator.of(context).pop();
  }

  void updateItem() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    final items = ref.read(itemsProvider.notifier);
    final updatedItem = widget.editingItem!.copyWith(
      title: _pickedName,
      daysUntilExpiry: _pickedDaysUntilExpiry,
      image: _pickedImage,
    );
    items.updateItem(updatedItem);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        title: Text(l10n.addNewItem),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isEditing && _pickedImage != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        child: Image.file(
                          _pickedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      )
                    : ItemImagePicker(
                        onImagePicked: onImagePicked,
                      ),
                const SizedBox(height: 16),
                Text(
                  l10n.itemName,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surface,
                  ),
                  child: TextFormField(
                    initialValue: _pickedName,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      hintText: l10n.nameHint,
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.nameIsEmpty;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _pickedName = value!;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.daysUntilExpiry,
                  style: theme.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.colorScheme.surface,
                  ),
                  child: TextFormField(
                    initialValue: _pickedDaysUntilExpiry.toString(),
                    keyboardType: TextInputType.number,
                    enableSuggestions: false,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      hintText: '0',
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return l10n.daysUntilExpiryInvalidValue;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _pickedDaysUntilExpiry = int.parse(value!);
                    },
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: _isEditing ? updateItem : saveItem,
                      style: ElevatedButton.styleFrom(
                        textStyle:
                            theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                      ),
                      child: Text(l10n.save)),
                ),
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        ref.read(itemsProvider.notifier).removeItem(widget.editingItem!);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        l10n.delete,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
