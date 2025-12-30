import 'package:piggy_log/VM/database_handler.dart';
import 'package:sqflite/sqlite_api.dart';

class MonthlyBudgetHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  Future<Database> _getDb() async {
    return await databaseHandler.database;
  }

  /// 이번달 예산 불러오기 (없으면 0 리턴)
Future<double> getMonthlyBudget(String yearMonth) async {
  // final db = await databaseHandler.initializeDB();
  final db = await _getDb();

  // 1. 먼저 이번 달 예산이 있는지 확인
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

  // 2. 이번 달 데이터가 없으면, 가장 최근에 설정했던 예산을 가져옴
  final lastRes = await db.query(
    'monthly_budget',
    columns: ['targetAmount'],
    where: 'c_id = 0 AND yearMonth < ?', // 현재 달보다 이전 기록들 중
    whereArgs: [yearMonth],
    orderBy: 'yearMonth DESC', // 가장 최근 순으로
    limit: 1,
  );

  if (lastRes.isEmpty) return 0.0;
  return (lastRes.first['targetAmount'] as num).toDouble();
}

  /// 이번달 예산 저장 (없으면 insert, 있으면 update)
  
  Future<void> saveMonthlyBudget(String yearMonth, double targetAmount) async {
  // final db = await databaseHandler.initializeDB();
  final db = await _getDb();

  // 1. 해당 월/카테고리에 이미 예산이 있는지 확인
  final List<Map<String, dynamic>> existing = await db.query(
    'monthly_budget',
    where: 'yearMonth = ? AND c_id = 0',
    whereArgs: [yearMonth],
  );

  if (existing.isNotEmpty) {
    // 2. 이미 있으면 업데이트 (기존 2천원을 3천원으로 수정)
    await db.update(
      'monthly_budget',
      {'targetAmount': targetAmount},
      where: 'yearMonth = ? AND c_id = 0',
      whereArgs: [yearMonth],
    );
  } else {
    // 3. 없으면 새로 추가
    await db.insert(
      'monthly_budget',
      {
        'c_id': 0,
        'yearMonth': yearMonth,
        'targetAmount': targetAmount,
      },
    );
  }
}
  // Future<void> saveMonthlyBudget(String yearMonth, double targetAmount) async {
  //   final db = await databaseHandler.initializeDB();

  //   await db.insert(
  //     'monthly_budget',
  //     {
  //       'c_id': 0, // 전체예산용 → 0 고정
  //       'yearMonth': yearMonth,
  //       'targetAmount': targetAmount,
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  /// 모든 월별 예산 기록 가져오기 (히스토리용)
  Future<List<Map<String, dynamic>>> getAllMonthlyBudgets() async {
    // final db = await databaseHandler.initializeDB();
    final db = await _getDb();

    // 전체 예산(c_id = 0) 기록만 최신순으로 가져옵니다.
    final List<Map<String, dynamic>> res = await db.query(
      'monthly_budget',
      where: 'c_id = 0',
      orderBy: 'yearMonth DESC',
    );

    return res;
  }

  
}
