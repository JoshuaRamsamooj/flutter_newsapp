import 'dart:convert';
import 'package:http/http.dart' show Client;
import '../models/item_model.dart';
import 'repository.dart';

class NewsApiProvider implements Source{
  Client client = Client();

  @override
  Future<List<int>> fetchTopIds() async {
    final encodedTopIds = await client.get('https://hacker-news.firebaseio.com/v0/topstories.json');
    final topIds = json.decode(encodedTopIds.body);
    return topIds.cast<int>();
  }

  @override
  Future<ItemModel> fetchItem(int id) async {
    final encodedItem = await client.get('https://hacker-news.firebaseio.com/v0/item/$id.json');
    final item = json.decode(encodedItem.body);
    return new ItemModel.fromJson(item);
  }
}