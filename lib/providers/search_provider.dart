import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridge_tracker/models/item.dart';
import 'package:fridge_tracker/providers/items_provider.dart';

class SearchStateProvider extends StateNotifier<String> {
  SearchStateProvider() : super('');

  void updateSearch(String value) {
    state = value;
  }
}

final searchProvider = StateNotifierProvider<SearchStateProvider, String>((ref) {
  return SearchStateProvider();
});

final filteredItemsProvider = Provider<List<Item>>((ref) {
  final search = ref.watch(searchProvider);
  final items = ref.watch(itemsProvider);

  if (search.isEmpty) {
    return items;
  }

  return items.where((item) => item.title.toLowerCase().contains(search.toLowerCase())).toList();
});
