import 'dart:async';
import 'news_api_provider.dart';
import 'news_db_provider.dart';
import '../models/item_model.dart';

class Repository {
  List<Source> sources = <Source>[
    newsDbProvider,
    NewsApiProvider(),
  ];

  List<Cache> caches = <Cache>[
    newsDbProvider,
  ];

  Future<List<int>> fetchTopIds() {
    // shortcut to call only NewsApiProvider()
    return sources[1].fetchTopIds();
  }

  Future<ItemModel> fetchItem(int id) async {
    print('Fetching $id');
    ItemModel item;
    Source source;
    var cache; //dynamic type to avoid comparison error in line 35

    for (source in sources) {
      item = await source.fetchItem(id);
      if (item != null) {
        break;
      }
    }

    for (cache in caches) {
      if (cache != source) {
        cache.addItem(item);
      }
    }

    return item;
  }

  clearCache() async {
    Cache cache;
    for (cache in caches) {
      await cache.clear(); // once there is await, the function intermediatdly will return a future (even without typing return)
    }
  }
}

abstract class Source {
  Future<List<int>> fetchTopIds();
  Future<ItemModel> fetchItem(int id);
}

abstract class Cache {
  Future<int> addItem(ItemModel item);
  Future<int> clear();
}
