import 'package:sqflite/sqlite_api.dart';
import 'database_handler.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Centralized data access for dashboard analytics. Optimized SQL queries 
//    with explicit aliases for better readability and performance.
//
//  * TODO: 
//    - Decouple data transformation logic (e.g., .map() to double) into a Service layer.
//    - Implement a caching mechanism for heavy aggregation queries.
// -----------------------------------------------------------------------------

class DashboardHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  Future<Database> _getDb() async {
    return await databaseHandler.database;
  }

  /// Fetches category-wise spending within a specific date range.
  Future<List<Map<String, dynamic>>> getCategoryExpenseByRange(String start, String end) async {
    final db = await _getDb();
    
    final result = await db.rawQuery("""
      SELECT 
        c.id, 
        c.c_name AS name,
        IFNULL(SUM(CASE WHEN t.type='expense' THEN t.amount ELSE 0 END), 0) AS total_expense,
        IFNULL(SUM(CASE WHEN t.type='income' THEN t.amount ELSE 0 END), 0) AS total_income
      FROM categories AS c
      LEFT JOIN spending_transactions AS t ON c.id = t.c_id 
      AND t.date BETWEEN ? AND ?
      GROUP BY c.id
    """, [start, end]);

    return result.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total_expense': (r['total_expense'] as num?)?.toDouble() ?? 0.0,
        'total_income': (r['total_income'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }
  
  /// Consolidated total expense calculation using modern query helper.
  Future<double> getMonthlyTotalExpense({String? yearMonth, String? startDate, String? endDate}) async {
    final db = await _getDb();
    final List<Map<String, dynamic>> result;

    if (startDate != null && endDate != null) {
      result = await db.query(
        'spending_transactions',
        columns: ['SUM(amount) AS total'],
        where: 'type = ? AND date BETWEEN ? AND ?',
        whereArgs: ['expense', startDate, endDate],
      );
    } else {
      result = await db.query(
        'spending_transactions',
        columns: ['SUM(amount) AS total'],
        where: 'type = ? AND date LIKE ?',
        whereArgs: ['expense', '$yearMonth%'],
      );
    }

    final value = result.first['total'];
    return (value != null ? (value as num).toDouble() : 0.0);
  }

  /// Category spending for a specific month.
  Future<List<Map<String, dynamic>>> getCategoryExpense(String yearMonth) async {
    final db = await _getDb();
    final result = await db.rawQuery("""
      SELECT 
        c.id, 
        c.c_name AS name,
        IFNULL(SUM(CASE WHEN t.type='expense' THEN t.amount ELSE 0 END), 0) AS total_expense,
        IFNULL(SUM(CASE WHEN t.type='income' THEN t.amount ELSE 0 END), 0) AS total_income
      FROM categories AS c
      LEFT JOIN spending_transactions AS t ON c.id = t.c_id AND t.date LIKE ?
      GROUP BY c.id
    """, ['$yearMonth%']);

    return result.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total_expense': (r['total_expense'] as num?)?.toDouble() ?? 0.0,
        'total_income': (r['total_income'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  /// Top 5 breakdown within a specific category.
  Future<Map<String, double>> getCategoryBreakdown(int categoryId) async {
    final db = await _getDb();
    final result = await db.query(
      'spending_transactions',
      columns: ['t_name', 'SUM(amount) AS total'],
      where: 'c_id = ? AND type = ?',
      whereArgs: [categoryId, 'expense'],
      groupBy: 't_name',
      orderBy: 'total DESC',
      limit: 5,
    );

    Map<String, double> map = {};
    for (var r in result) {
      map[r['t_name'] as String] = (r['total'] as num?)?.toDouble() ?? 0.0;
    }
    return map;
  }

  /// Fetches recent transactions with joined category metadata.
  Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 5}) async {
    final db = await _getDb();
    final result = await db.rawQuery("""
      SELECT 
        t.*, 
        c.icon_codepoint, c.icon_font_family, c.icon_font_package, c.color
      FROM spending_transactions AS t
      LEFT JOIN categories AS c ON t.c_id = c.id
      ORDER BY t.date DESC LIMIT ?
    """, [limit]);

    return result.map((row) {
      return {
        ...row,
        'icon_codepoint': row['icon_codepoint'],
        'icon_font_family': row['icon_font_family'],
        'icon_font_package': row['icon_font_package'],
        'color': row['color'],
      };
    }).toList();
  }

  /// Get templates for recurring items.
Future<List<Map<String, dynamic>>> getRecurringTemplates() async {
  final db = await _getDb();
  return await db.query(
    'spending_transactions',
    where: 'isRecurring = ?',
    whereArgs: [1],
    groupBy: 't_name', 
  );
}

  /// Duplicate check for monthly recurring tasks.
  Future<bool> checkIfAlreadyAdded(String title, double amount, String yearMonth) async {
    final db = await _getDb();
    final result = await db.query(
      'spending_transactions',
      where: 't_name = ? AND amount = ? AND date LIKE ?',
      whereArgs: [title, amount, '$yearMonth%'],
    );
    return result.isNotEmpty;
  }

  /// Raw insertion helper.
  Future<void> insertTransaction(Map<String, dynamic> data) async {
    final db = await _getDb();
    await db.insert('spending_transactions', data);
  }

  /// Detailed category history.
  Future<List<Map<String, dynamic>>> getCategoryDetailedList(int categoryId) async {
    final db = await _getDb();
    return await db.query(
      'spending_transactions', 
      where: 'c_id = ? AND type = ?', 
      whereArgs: [categoryId, 'expense'],
      orderBy: 'date ASC'
    );
  }
}