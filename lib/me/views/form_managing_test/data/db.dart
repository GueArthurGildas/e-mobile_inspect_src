import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class AppDb {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inspection_bis.db');

    // 📌 À activer temporairement si tu veux forcer la recréation
    //await deleteDatabase(path);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE inspection (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            json_field TEXT NOT NULL DEFAULT '{}'
          );
        ''');
      },
    );

    return _db!;
  }
}

