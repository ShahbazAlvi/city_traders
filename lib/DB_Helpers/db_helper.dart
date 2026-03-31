import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String path = join(await getDatabasesPath(), 'items.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE items(
          id TEXT PRIMARY KEY,
          name TEXT,
          salePrice REAL,
          minLevelQty REAL,
          image TEXT,
          isSynced INTEGER,
          createdAt TEXT
        )
        ''');
      },
    );
  }
}