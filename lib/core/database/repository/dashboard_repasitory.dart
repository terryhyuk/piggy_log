import 'package:sqflite/sqflite.dart';
import 'package:piggy_log/core/database/database_service.dart';

class DashboardRepository {
  // Constructor no longer requires db injection
  DashboardRepository();

  // Getter to always retrieve a fresh database instance
  Future<Database> get _db async => await DatabaseService().database;

  // --- [Budget Logic] ---

  Future<double> getMonthlyBudget(String yearMonth) async {
    final db = await _db;
    final res = await db.query(
      'monthly_budgets',
      columns: ['target_amount'],
      where: 'year_month = ?',
      whereArgs: [yearMonth],
      limit: 1,
    );

    if (res.isNotEmpty) {
      return (res.first['target_amount'] as num).toDouble();
    }

    final lastRes = await db.query(
      'monthly_budgets',
      columns: ['target_amount'],
      where: 'year_month < ?',
      whereArgs: [yearMonth],
      orderBy: 'year_month DESC',
      limit: 1,
    );

    return lastRes.isEmpty
        ? 0.0
        : (lastRes.first['target_amount'] as num).toDouble();
  }

  Future<void> saveMonthlyBudget(String yearMonth, double targetAmount) async {
    final db = await _db;
    await db.insert(
      'monthly_budgets',
      {
        'year_month': yearMonth,
        'target_amount': targetAmount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllMonthlyBudgets() async {
    final db = await _db;
    return await db.query('monthly_budgets', orderBy: 'year_month DESC');
  }


  Future<List<Map<String, dynamic>>> getCategoryExpensesByRange(
    String start,
    String end,
  ) async {
    final db = await _db;
    return await db.rawQuery(
      """
      SELECT 
        c.id, 
        c.name,
        IFNULL(SUM(CASE WHEN r.type='expense' THEN r.amount ELSE 0 END), 0) AS total_expense,
        IFNULL(SUM(CASE WHEN r.type='income' THEN r.amount ELSE 0 END), 0) AS total_income
      FROM categories AS c
      LEFT JOIN records AS r ON c.id = r.category_id 
      AND r.date BETWEEN ? AND ?
      GROUP BY c.id
    """,
      [start, end],
    );
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions({
    int limit = 5,
  }) async {
    final db = await _db;
    return await db.rawQuery(
      """
      SELECT 
        r.*, 
        c.icon_codepoint, c.icon_font_family, c.icon_font_package, c.color
      FROM records AS r
      LEFT JOIN categories AS c ON r.category_id = c.id
      ORDER BY r.date DESC, r.id DESC 
      LIMIT ?
    """,
      [limit],
    );
  }

  Future<Map<String, double>> getCategoryBreakdown(
    int categoryId,
    String start,
    String end,
  ) async {
    final db = await _db;
    final result = await db.query(
      'records',
      columns: ['name', 'SUM(amount) AS total'],
      where: 'category_id = ? AND type = ? AND date BETWEEN ? AND ?',
      whereArgs: [categoryId, 'expense', start, end],
      groupBy: 'name',
      orderBy: 'total DESC',
      limit: 5,
    );

    return {
      for (var r in result) r['name'] as String: (r['total'] as num).toDouble(),
    };
  }

  Future<bool> checkDuplicateTransaction(
    String name,
    double amount,
    String yearMonth,
  ) async {
    final db = await _db;
    final result = await db.query(
      'records',
      where: 'name = ? AND amount = ? AND date LIKE ?',
      whereArgs: [name, amount, '$yearMonth%'],
    );
    return result.isNotEmpty;
  }

  Future<void> insertTransaction(Map<String, dynamic> data) async {
    final db = await _db;
    await db.insert('records', data);
  }

  Future<double> getCategoryTotalByDate(int categoryId, String date) async {
    final db = await _db;
    final List<Map<String, dynamic>> result = await db.query(
      'records',
      columns: ['SUM(amount) AS total'],
      where: 'category_id = ? AND type = ? AND date = ?',
      whereArgs: [categoryId, 'expense', date],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}