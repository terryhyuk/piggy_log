import 'package:sqflite/sqlite_api.dart';
import 'database_handler.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Managing monthly financial goals with smart fallback logic to ensure 
//    continuity in user budget tracking even if current records are missing.
//
//  * TODO: 
//    - Migrate budget calculation and historical comparison logic to a Service layer.
//    - Integrate with a notification service for budget alerts.
// -----------------------------------------------------------------------------

class MonthlyBudgetHandler {
  final DatabaseHandler _dbHandler = DatabaseHandler();

  Future<Database> _getDb() async => await _dbHandler.database;

  /// Retrieves the budget for a specific month.
  /// Strategy: Attempts to find the exact month's budget; 
  /// otherwise, falls back to the most recent historical record.
  Future<double> getMonthlyBudget(String yearMonth) async {
    final db = await _getDb();

    // [Step 1] Attempt to retrieve current month's budget
    final res = await db.query(
      'monthly_budget',
      columns: ['targetAmount'],
      where: 'yearMonth = ? AND c_id = 0',
      whereArgs: [yearMonth],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return (res.first['targetAmount'] as num).toDouble();
    }

    // [Step 2] Fallback to the latest record prior to the target month
    final lastRes = await db.query(
      'monthly_budget',
      columns: ['targetAmount'],
      where: 'c_id = 0 AND yearMonth < ?',
      whereArgs: [yearMonth],
      orderBy: 'yearMonth DESC',
      limit: 1,
    );

    if (lastRes.isEmpty) return 0.0;
    return (lastRes.first['targetAmount'] as num).toDouble();
  }

  /// Saves or updates the budget record for the given month.
  Future<void> saveMonthlyBudget(String yearMonth, double targetAmount) async {
    final db = await _getDb();

    final List<Map<String, dynamic>> existing = await db.query(
      'monthly_budget',
      where: 'yearMonth = ? AND c_id = 0',
      whereArgs: [yearMonth],
    );

    if (existing.isNotEmpty) {
      await db.update(
        'monthly_budget',
        {'targetAmount': targetAmount},
        where: 'yearMonth = ? AND c_id = 0',
        whereArgs: [yearMonth],
      );
    } else {
      await db.insert(
        'monthly_budget',
        {
          'c_id': 0, // 0 as the global total budget identifier
          'yearMonth': yearMonth,
          'targetAmount': targetAmount,
        },
      );
    }
  }

  /// Returns all historical budget entries sorted by date.
  Future<List<Map<String, dynamic>>> getAllMonthlyBudgets() async {
    final db = await _getDb();
    return await db.query(
      'monthly_budget',
      where: 'c_id = 0',
      orderBy: 'yearMonth DESC',
    );
  }
}