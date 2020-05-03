import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'dart:async';
import '../models/item_model.dart';
import 'repository.dart';

class NewsDbProvider implements Source, Cache{
  // Database instance variable
  Database db;

  NewsDbProvider() {
    init();
  }

  void init() async { // since we cannot do async in Constructor
    Directory documentsDirectory = await getApplicationDocumentsDirectory(); // reference to directory on device
    final path = join(documentsDirectory.path, "items.db"); // join the path to the db to get access to db itself
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database newDb, int version) { // called the first time the user starts the application
        newDb.execute("""
        CREATE TABLE Items
          (
            id INTEGER PRIMARY KEY,
            deleted INTEGER,
            type TEXT,
            by TEXT,
            time INTEGER,
            text TEXT ,
            dead integer,
            parent INTEGER,
            kids BLOB,
            url TEXT,
            score INTEGER,
            title TEXT,
            descendants INTEGER
          )
        """);
      }
    );
  }

  @override
  Future<List<int>> fetchTopIds() async {
    // never going to call in this app, just satisfying the abstract class reqs
    return null;
  }

  @override
  Future<ItemModel> fetchItem(int id) async {
    // this is going to return a list of map objects so we will call it maps
    final maps = await db.query(
      "Items",
      columns: null, // all columns
      where: "id = ?",
      whereArgs: [id], // avoids sql injection
    );

    if (maps.length > 0) {
      // we only expect it to receive one map
      return ItemModel.fromDb(maps.first);
    }
    return null;
  }

  @override
  Future<int> addItem(ItemModel item) {
    // Don't need to wait for the result of the insertion. Fire and Forget method. That's why we don't need the await keyword.
    return db.insert("Items", item.toMapForDb());
  }

  Future<int> clear() {
    return db.delete('Items');
  }
}

final newsDbProvider = NewsDbProvider();