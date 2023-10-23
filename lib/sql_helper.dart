import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE event_list (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          event_name CHAR(100) NULL,
          date TIMESTAMP NULL,
          location VARCHAR(100) NULL,
          description VARCHAR(100) NULL,
          fav_status CHAR(1) NULL,
          timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    sql.databaseFactory = databaseFactoryFfi;
    return sql.openDatabase(
      'event.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item
  static Future<int> createItem(
    String? eventName,
    String? date,
    String? location,
    String? description,
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'event_name': eventName,
      'date': date,
      'location': location,
      'description': description,
      'fav_status': "F",
    };
    final id = await db.insert('event_list', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('event_list', orderBy: "date");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItemFav() async {
    final db = await SQLHelper.db();
    return db.query('event_list', where: "fav_status = ?", whereArgs: ['T']);
  }

  // Update an item by id
  static Future<int> updateItem(
    int id,
    String? event_name,
    String? date,
    String? location,
    String? description,
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'event_name': event_name,
      'date': date,
      'location': location,
      'description': description,
    };

    final result =
        await db.update('event_list', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Update fav item by id
  static Future<int> updateItemFav(int id, String favStatus) async {
    final db = await SQLHelper.db();

    final data = {
      'fav_status': favStatus,
    };

    final result =
        await db.update('event_list', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("event_list", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
