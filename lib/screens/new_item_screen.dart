import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_tracker/factories/notifications_service.dart';
import 'package:fridge_tracker/models/item.dart';
import 'package:fridge_tracker/providers/items_provider.dart';
import 'package:fridge_tracker/widgets/item_image_picker.dart';

final _notifications = NotificationsService();

class NewItemScreen extends ConsumerStatefulWidget {
  const NewItemScreen({super.key, this.editingItem});

  final Item? editingItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends ConsumerState<NewItemScreen> {
  late AppLocalizations l10n;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _daysInputController = TextEditingController(text: '1');
  var _isEditing = false;
  File? _pickedImage;
  var _pickedName = '';
  var _pickedDaysUntilExpiry = 1;

  @override
  void initState() {
    super.initState();
    if (widget.editingItem != null) {
      _pickedName = widget.editingItem!.title;
      _pickedImage = widget.editingItem!.image;
      _pickedDaysUntilExpiry = widget.editingItem!.daysUntilExpiry!;
      _daysInputController.text = _pickedDaysUntilExpiry.toString();
      _isEditing = true;
    }
  }

  void onImagePicked(File? pickedImage) {
    _pickedImage = pickedImage;
  }

  Future<void> saveItem() async {
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
    newItem.notificationId = _pickedName.hashCode;
    items.addItem(newItem);

    if (await _notifications.requestPermission()) {
      _notifications.scheduleNotification(
        newItem.notificationId,
        newItem.title,
        Duration(hours: newItem.expiryDate!.subtract(const Duration(days: 1)).hour),
        l10n.itemExpiresSoon_notification(newItem.title),
        newItem.image,
      );
    }

    if (!mounted) return;
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
    l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        title: Text(_isEditing ? _pickedName : l10n.addNewItem),
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
                    ? Hero(
                        tag: _pickedImage!,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          child: Image.file(
                            _pickedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200,
                          ),
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
                    controller: _daysInputController,
                    keyboardType: TextInputType.number,
                    enableSuggestions: false,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    onTap: () => _daysInputController.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _daysInputController.value.text.length,
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
                          int.parse(value) < 1) {
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
