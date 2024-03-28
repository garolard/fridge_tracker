import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

class ItemImagePicker extends StatefulWidget {
  const ItemImagePicker({super.key, required this.onImagePicked});

  final void Function(File? pickedImage) onImagePicked;

  @override
  State<ItemImagePicker> createState() => _ItemImagePickerState();
}

class _ItemImagePickerState extends State<ItemImagePicker> {
  File? pickedImage;

  void pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera, maxHeight: 1200);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      this.pickedImage = File(pickedImage.path);
    });

    widget.onImagePicked(this.pickedImage);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Widget content = pickedImage == null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                color: theme.colorScheme.onSurface,
              ),
              Text(
                l10n.addImage,
                style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurface),
              ),
            ],
          )
        : Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Image.file(
                pickedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IconButton(
                onPressed: () => setState(() {
                  pickedImage = null;
                  widget.onImagePicked(null);
                }),
                icon: Icon(
                  Icons.delete_outline,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset.fromDirection(1.57),
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                color: theme.colorScheme.surface,
              ),
            ),
          ]);

    return InkWell(
      onTap: pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Center(
          child: content,
        ),
      ),
    );
  }
}
