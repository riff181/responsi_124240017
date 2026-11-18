import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get instance async => _db ??= await _open();

  static Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'shoppinghub.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE session(
            id INTEGER PRIMARY KEY CHECK (id = 1),
            username TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE wishlist(
            product_id INTEGER NOT NULL,
            username TEXT NOT NULL,
            title TEXT,
            category TEXT,
            price REAL,
            thumbnail TEXT,
            PRIMARY KEY (product_id, username)
          )
        ''');
      },
    );
  }
}
