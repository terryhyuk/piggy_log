import 'package:sqflite/sqflite.dart';
import 'package:piggy_log/core/database/database_service.dart';

class CalendarRepository {
  CalendarRepository();

  Future<Database> get _db async => await DatabaseService().database;

  /// Fetches daily net totals (Income - Expense).
  Future<Map<String, double>> getDailyTotals() async {
    final db = await _db;
    final result = await db.rawQuery(
      """
      SELECT date, SUM(CASE WHEN type='expense' THEN -amount ELSE amount END) as total
      FROM records
      GROUP BY date
      """
    );

    return {
      for (var r in result) 
        r['date'] as String: (r['total'] as num?)?.toDouble() ?? 0.0
    };
  }

  /// Retrieves records records for a specific date.
  Future<List<Map<String, dynamic>>> getTransactionsByDate(String date) async {
    final db = await _db;
    return await db.query(
      'records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
  }

  // --- Category Logic ---

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await _db;
    return await db.query('categories');
  }

  Future<void> insertCategory(Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert('categories', data);
  }

  Future<void> updateCategory(Map<String, dynamic> data) async {
    final db = await _db;
    await db.update(
      'categories', 
      data, 
      where: 'id = ?', 
      whereArgs: [data['id']]
    );
  }
}