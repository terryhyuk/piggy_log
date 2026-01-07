import 'package:piggy_log/core/db/database_handler.dart';
import 'package:piggy_log/features/transaction/model/spending_transaction.dart';
import 'package:sqflite/sqlite_api.dart';

// -----------------------------------------------------------------------------
//  * TransactionHandler.dart
//  -----------------------------------------------------------------------------
//  * [Diary]
//  * 1. Date Sanitization: Prevents future dates and standardizes YYYY-MM-DD.
//  * 2. Debug Traces: Essential logs for verifying cash flow data during entry.
//  * 3. Robust Aggregation: Safe num-to-double conversion for category totals.
// -----------------------------------------------------------------------------

class TransactionHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  Future<Database> _getDb() async {
    return await databaseHandler.database;
  }

  /// Inserts a new transaction with date validation.
  Future<int> insertTransaction(
    SpendingTransaction res, {
    DateTime? customDate,
  }) async {
    final db = await _getDb();

    // 1️⃣ Resolve Target Date
    DateTime date = customDate ?? DateTime.now();

    // 2️⃣ Prevent Future Dates (Standardize to Today if needed)
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.isAfter(todayOnly)) {
      date = todayOnly;
    } else {
      date = dateOnly;
    }

    // 3️⃣ DB Format: YYYY-MM-DD
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    // [Trace] Verifying the final data package before DB entry

    // 4️⃣ DB Insert using Helper Method
    return await db.insert('spending_transactions', {
      'c_id': res.c_id,
      't_name': res.t_name,
      'date': dateStr,
      'type': res.type,
      'amount': res.amount,
      'memo': res.memo,
      'isRecurring': res.isRecurring ? 1 : 0,
    });
  }

  /// Fetches transactions for a specific category, newest first.
  Future<List<SpendingTransaction>> getTransactionsByCategory(int categoryId) async {
    final db = await _getDb();
    
    
    final result = await db.query(
      'spending_transactions',
      where: 'c_id = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );

    return result.map((e) => SpendingTransaction.fromMap(e)).toList();
  }

  /// Updates an existing transaction record.
  Future<int> updateTransaction(SpendingTransaction trx) async {
    final db = await _getDb();
    
    return await db.update(
      'spending_transactions',
      {
        't_name': trx.t_name,
        'c_id': trx.c_id,
        'date': trx.date,
        'type': trx.type,
        'amount': trx.amount,
        'memo': trx.memo,
        'isRecurring': trx.isRecurring ? 1 : 0,
      },
      where: 't_id = ?',
      whereArgs: [trx.t_id],
    );
  }

  /// Calculates the aggregate total for a specific category.
  Future<double> getCategoryTotal(int categoryId) async {
    final db = await _getDb();

    final List<Map<String, dynamic>> result = await db.query(
      'spending_transactions',
      columns: ['SUM(amount) AS total'],
      where: 'c_id = ?',
      whereArgs: [categoryId],
    );

    final value = result.first['total'];
    
    return value == null ? 0.0 : (value as num).toDouble();
  }

  /// Deletes a specific transaction.
  Future<void> deleteTransaction(int transactionId) async {
    final db = await _getDb();
    
    await db.delete(
      'spending_transactions',
      where: 't_id = ?',
      whereArgs: [transactionId],
    );
  }
}