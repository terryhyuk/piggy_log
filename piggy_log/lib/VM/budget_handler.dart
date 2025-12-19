import 'package:sqflite/sqflite.dart';
import 'package:simple_spending_tracker/VM/database_handler.dart';

class MonthlyBudgetHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  /// 이번달 예산 불러오기 (없으면 0 리턴)
  Future<double> getMonthlyBudget(String yearMonth) async {
    final db = await databaseHandler.initializeDB();

    final res = await db.query(
      'monthly_budget',
      columns: ['targetAmount'],
      where: 'yearMonth = ? AND c_id = 0',
      whereArgs: [yearMonth],
      limit: 1,
    );

    if (res.isEmpty) return 0.0;
    return (res.first['targetAmount'] as num).toDouble();
  }

  /// 이번달 예산 저장 (없으면 insert, 있으면 update)
  Future<void> saveMonthlyBudget(String yearMonth, double targetAmount) async {
    final db = await databaseHandler.initializeDB();

    await db.insert(
      'monthly_budget',
      {
        'c_id': 0, // 전체예산용 → 0 고정
        'yearMonth': yearMonth,
        'targetAmount': targetAmount,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
