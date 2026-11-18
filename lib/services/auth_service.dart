import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class AuthService {
  static String? _current;

  static Future<void> init() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('session', limit: 1);
    _current = rows.isEmpty ? null : rows.first['username'] as String;
  }

  static bool get isLoggedIn => _current != null;
  static String get username => _current ?? '';

  static String _hash(String p) => sha256.convert(utf8.encode(p)).toString();

  static Future<void> _saveSession(Database db, String username) async {
    await db.insert(
      'session',
      {'id': 1, 'username': username},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _current = username;
  }

  static Future<String?> register(String username, String password) async {
    final u = username.trim();
    final db = await AppDatabase.instance;
    final exist =
        await db.query('users', where: 'username = ?', whereArgs: [u], limit: 1);
    if (exist.isNotEmpty) return 'Username sudah terdaftar';
    await db.insert('users', {'username': u, 'password': _hash(password)});
    await _saveSession(db, u);
    return null;
  }

  static Future<String?> login(String username, String password) async {
    final u = username.trim();
    final db = await AppDatabase.instance;
    final rows =
        await db.query('users', where: 'username = ?', whereArgs: [u], limit: 1);
    if (rows.isEmpty) return 'Username belum terdaftar';
    if (rows.first['password'] != _hash(password)) return 'Password salah';
    await _saveSession(db, u);
    return null;
  }

  static Future<void> logout() async {
    final db = await AppDatabase.instance;
    await db.delete('session');
    _current = null;
  }
}
