import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../models/shopping.dart';
import 'auth_service.dart';
import 'database_helper.dart';

class WishlistService {
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void _notify() => changes.value++;

  static Future<bool> has(int id) async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'wishlist',
      columns: ['product_id'],
      where: 'product_id = ? AND username = ?',
      whereArgs: [id, AuthService.username],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  static Future<void> add(Shopping p) async {
    final db = await AppDatabase.instance;
    await db.insert(
      'wishlist',
      {
        'product_id': p.id,
        'username': AuthService.username,
        'title': p.title,
        'category': p.category,
        'price': p.price,
        'thumbnail': p.thumbnail,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _notify();
  }

  static Future<void> remove(int id) async {
    final db = await AppDatabase.instance;
    await db.delete(
      'wishlist',
      where: 'product_id = ? AND username = ?',
      whereArgs: [id, AuthService.username],
    );
    _notify();
  }

  static Future<bool> toggle(Shopping p) async {
    if (await has(p.id)) {
      await remove(p.id);
      return false;
    }
    await add(p);
    return true;
  }

  static Future<List<Shopping>> getAll() async {
    final db = await AppDatabase.instance;
    final rows = await db.query(
      'wishlist',
      where: 'username = ?',
      whereArgs: [AuthService.username],
      orderBy: 'rowid DESC',
    );
    return rows
        .map((r) => Shopping(
              id: r['product_id'] as int,
              title: (r['title'] as String?) ?? '',
              category: (r['category'] as String?) ?? '',
              price: (r['price'] as num?)?.toDouble() ?? 0,
              thumbnail: (r['thumbnail'] as String?) ?? '',
            ))
        .toList();
  }
}
