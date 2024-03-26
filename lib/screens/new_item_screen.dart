import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_tracker/models/item.dart';
import 'package:fridge_tracker/providers/items_provider.dart';
import 'package:fridge_tracker/widgets/item_image_picker.dart';

class NewItemScreen extends ConsumerStatefulWidget {
  const NewItemScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends ConsumerState<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  var _pickedName = '';
  var _pickedDaysUntilExpiry = 0;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image picker
                ItemImagePicker(
                  onImagePicked: onImagePicked,
                ),
                const SizedBox(height: 16),
                Text(
                  'Name',
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
                    enableSuggestions: false,
                    autocorrect: false,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      hintText: 'Enter name',
                      border: InputBorder.none,
                      hintStyle: theme.textTheme.bodyLarge!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
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
                  'Days until expiry',
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
                        return 'Please enter one or more days';
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
                      onPressed: saveItem,
                      style: ElevatedButton.styleFrom(
                        textStyle:
                            theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                      ),
                      child: const Text('Save')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
