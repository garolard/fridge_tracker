import 'dart:io';

import 'package:fridge_tracker/extensions/list_extensions.dart';
import 'package:path_provider/path_provider.dart' as syspath;
import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart' as sqlite;

import 'package:fridge_tracker/models/item.dart';
import 'package:riverpod/riverpod.dart';

const _fridgeItemsTableName = 'fridge_items';

Future<sqlite.Database> _getDatabase() async {
  final dbPath = await syspath.getApplicationDocumentsDirectory();
  final db = await sql.openDatabase(
    path.join(dbPath.path, 'fridge_items.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE $_fridgeItemsTableName(id TEXT PRIMARY KEY, title TEXT, imagePath TEXT, expiryDate TEXT, notificationId INTEGER)',
      );
    },
    version: 1,
  );

  return db;
}

class ItemsProviderNotifier extends StateNotifier<List<Item>> {
  ItemsProviderNotifier() : super([]);

  Future<void> loadItems() async {
    final db = await _getDatabase();
    final itemsData = await db.query(_fridgeItemsTableName);
    final appDir = await syspath.getApplicationDocumentsDirectory();

    final items = itemsData
        .map((itemData) => Item.existing(
              id: itemData['id'] as String,
              title: itemData['title'] as String,
              image: itemData['imagePath'] != null && (itemData['imagePath'] as String).isNotEmpty
                  ? File(path.join('${appDir.path}/${itemData['imagePath'] as String}'))
                  : null,
              expiryDate: DateTime.parse(itemData['expiryDate'] as String),
              notificationId: itemData['notificationId'] as int,
            ))
        .toList();

    state = items.sorted<Item, DateTime>((a) => a.expiryDate!);
  }

  void addItem(Item item) async {
    if (item.image != null) {
      final appDir = await syspath.getApplicationDocumentsDirectory();
      final fileName = path.basename(item.image!.path);
      final copiedImage = await item.image!.copy('${appDir.path}/$fileName');
      item.image = copiedImage;
    }

    final db = await _getDatabase();

    db.insert(_fridgeItemsTableName, {
      'id': item.id,
      'title': item.title,
      'imagePath': item.image == null ? null : path.basename(item.image!.path),
      'expiryDate': item.expiryDate?.toIso8601String(),
      'notificationId': item.notificationId,
    });

    state = [...state, item].sorted<Item, DateTime>((x) => x.expiryDate!);
  }

  void removeItem(Item item) async {
    if (item.image != null) {
      item.image!.delete();
    }

    final db = await _getDatabase();
    db.delete(
      _fridgeItemsTableName,
      where: 'id = ?',
      whereArgs: [item.id],
    );

    state = state
        .where((element) => element != item)
        .toList()
        .sorted<Item, DateTime>((x) => x.expiryDate!);
  }

  void updateItem(Item item) async {
    final db = await _getDatabase();
    db.update(
      _fridgeItemsTableName,
      {
        'title': item.title,
        'expiryDate': item.expiryDate?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [item.id],
    );

    await loadItems();
  }
}

final itemsProvider = StateNotifierProvider<ItemsProviderNotifier, List<Item>>((ref) {
  return ItemsProviderNotifier();
});
