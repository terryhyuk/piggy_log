import 'package:sqflite/sqflite.dart';
import 'database_handler.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Optimizing calendar-specific data retrieval. Offloaded net-total 
//    calculations to the SQL engine to minimize application-side processing.
//
//  * TODO: 
//    - Implement date-range filtering to avoid loading all-time data at once.
//    - Transfer result mapping logic to a Domain-specific model.
// -----------------------------------------------------------------------------

class CalenderHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  /// Private helper for stable DB instance retrieval.
  Future<Database> _getDb() async {
    return await databaseHandler.database; 
  }

  /// Fetches daily net totals (Total Income - Total Expense).
  /// Aggregates data at the database level for better performance.
  Future<Map<String, double>> getDailyTotals() async {
    final db = await _getDb();
    
    final result = await db.rawQuery(
      """
      SELECT date, SUM(CASE WHEN type='expense' THEN -amount ELSE amount END) as total
      FROM spending_transactions
      GROUP BY date
      """
    );

    Map<String, double> map = {};
    for (var r in result) {
      map[r['date'] as String] = (r['total'] as num?)?.toDouble() ?? 0.0;
    }
    return map;
  }

  /// Retrieves all transaction details for a specific date (YYYY-MM-DD).
  Future<List<Map<String, dynamic>>> getTransactionsByDate(String date) async {
    final db = await _getDb();
    
    final result = await db.rawQuery(
      """
      SELECT t_id, t_name, amount, type, memo, c_id, isRecurring
      FROM spending_transactions
      WHERE date = ?
      ORDER BY t_id DESC
      """,
      [date],
    );

    return result.map((r) => {
      't_id': r['t_id'],
      't_name': r['t_name'],
      'amount': (r['amount'] as num?)?.toDouble() ?? 0.0,
      'type': r['type'],
      'memo': r['memo'],
      'c_id': r['c_id'],
      'isRecurring': r['isRecurring'],
    }).toList();
  }
}