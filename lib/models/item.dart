import 'dart:io';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Item {
  String id;
  String title;
  File? image;
  int? daysUntilExpiry;
  DateTime expiryDate;
  int notificationId = 0;

  Item({
    required this.title,
    required this.image,
    required this.daysUntilExpiry,
  })  : id = _uuid.v8(),
        expiryDate = DateTime.now().add(
          Duration(days: daysUntilExpiry!),
        );

  Item.existing({
    required this.id,
    required this.title,
    required this.image,
    required this.expiryDate,
    required this.notificationId,
  });

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
    newItem.notificationId = notificationId;
    return newItem;
  }

  bool get isExpired => expiryDate.difference(DateTime.now()).inDays <= 0;
}
