import 'dart:io';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Item {
  String id;
  String title;
  File? image;
  int? daysUntilExpiry;
  DateTime? expiryDate;
  bool isExpired = false;

  Item({
    required this.title,
    required this.image,
    required this.daysUntilExpiry,
  })  : id = _uuid.v8(),
        expiryDate = DateTime.now().add(
          Duration(days: daysUntilExpiry!),
        ) {
    isExpired = false;
  }

  Item.existing({
    required this.id,
    required this.title,
    required this.image,
    required this.expiryDate,
  }) {
    isExpired = DateTime.now().isAfter(expiryDate!);
  }

  Item copyWith({
    String? title,
    File? image,
    int? daysUntilExpiry,
  }) {
    var newItem = Item(
      title: title ?? this.title,
      image: image ?? this.image,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
    );
    newItem.id = id;
    return newItem;
  }
}
