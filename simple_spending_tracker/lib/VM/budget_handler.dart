// lib/VM/monthly_budget_handler.dart

import 'package:simple_spending_tracker/model/monthlybudget.dart';
import 'package:sqflite/sqflite.dart';
import 'package:simple_spending_tracker/VM/database_handler.dart';

class MonthlyBudgetHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  // Initialize monthly budget for a category with 0 if not exists
  Future<void> initMonthlyBudget(int cid, String yearMonth) async {
    final db = await databaseHandler.initializeDB();

    final existing = await db.query(
      'monthly_budget',
      where: 'c_id = ? AND yearMonth = ?',
      whereArgs: [cid, yearMonth],
    );

    if (existing.isEmpty) {
      await db.insert(
        'monthly_budget',
        {
          'c_id': cid,
          'yearMonth': yearMonth,
          'targetAmount': 0.0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Update monthly budget for a category
  Future<void> updateMonthlyBudget(int cid, String yearMonth, double target) async {
    final db = await databaseHandler.initializeDB();

    await db.update(
      'monthly_budget',
      {'targetAmount': target},
      where: 'c_id = ? AND yearMonth = ?',
      whereArgs: [cid, yearMonth],
    );
  }

  // Get monthly budget for a category (returns 0 if not exists)
  Future<double> getMonthlyBudget(int cId, String yearMonth) async {
    final db = await databaseHandler.initializeDB();

    final res = await db.query(
      'monthly_budget',
      columns: ['targetAmount'],
      where: 'c_id = ? AND yearMonth = ?',
      whereArgs: [cId, yearMonth],
    );

    if (res.isEmpty) return 0.0;
    return (res.first['targetAmount'] as num?)?.toDouble() ?? 0.0;
  }

  // --------------------------
  // Get all monthly budgets for a specific month
  // returns list of Monthlybudget
  // --------------------------
  Future<List<Monthlybudget>> getMonthlyBudgets(String yearMonth) async {
    final db = await databaseHandler.initializeDB();

    final res = await db.query(
      'monthly_budget',
      where: 'yearMonth = ?',
      whereArgs: [yearMonth],
    );

    return res.map((r) => Monthlybudget.fromMap(r)).toList();
  }
}
