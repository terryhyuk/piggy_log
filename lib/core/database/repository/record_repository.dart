import 'package:sqflite/sqflite.dart';
import 'package:piggy_log/core/database/database_service.dart';
import 'package:piggy_log/data/models/record_model.dart';

class RecordRepository {
  final DatabaseService _dbService = DatabaseService();

  // Getter to always retrieve the latest database connection
  Future<Database> get _db async => await _dbService.database;

  /// Fetches records associated with a specific category
  Future<List<RecordModel>> getRecordsByCategoryId(int categoryId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'records',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return maps.map((e) => RecordModel.fromMap(e)).toList();
  }

  /// Inserts a new records record
  Future<int> insertRecord(RecordModel record) async {
    final db = await _db;
    return await db.insert(
      'records',
      {
        'category_id': record.categoryId,
        'name': record.name,
        'date': record.date,
        'type': record.type,
        'amount': record.amount,
        'memo': record.memo,
        'is_recurring': record.isRecurring ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Updates an existing records record
  Future<int> updateRecord(RecordModel record) async {
    final db = await _db;
    return await db.update(
      'records',
      {
        'name': record.name,
        'date': record.date,
        'type': record.type,
        'amount': record.amount,
        'memo': record.memo,
        'is_recurring': record.isRecurring ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// Deletes a specific records record
  Future<int> deleteRecord(int id) async {
    final db = await _db;
    return await db.delete(
      'records', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

    // --- [records Logic] ---

  Future<double> getMonthlyTotalExpense({
    required String start,
    required String end,
  }) async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.query(
      'records',
      columns: ['SUM(amount) AS total'],
      where: 'type = ? AND date BETWEEN ? AND ?',
      whereArgs: ['expense', start, end],
    );

    final value = result.first['total'];
    return (value != null ? (value as num).toDouble() : 0.0);
  }

    // --- [Auto-Insert Logic] ---
Future<List<Map<String, dynamic>>> getRecurringTemplates() async {
  final db = await _db;
  
  return await db.query(
    'records',
    where: 'is_recurring = ?',
    whereArgs: [1],
    groupBy: 'name, date', 
    orderBy: 'date ASC', 
  );
}

Future<bool> checkDuplicateRecord(String name, double amount, String yearMonth) async {
  final db = await _db; 
  
  final List<Map<String, dynamic>> maps = await db.query(
    'records',
    where: 'name = ? AND amount = ? AND date LIKE ?',
    whereArgs: [name, amount, '$yearMonth%'],
  );
  
  return maps.isNotEmpty;
}

Future<int> getTotalRecordCount() async {
  final db = await _db;
  final result = await db.rawQuery('SELECT COUNT(*) as count FROM records');
  return (result.first['count'] as int?) ?? 0;
}
}