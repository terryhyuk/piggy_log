import 'database_handler.dart';

class DashboardHandler {
  final DatabaseHandler dbHandler = DatabaseHandler();

/// 이번 달 총 지출
Future<double> getMonthlyTotalExpense(String yearMonth) async {
  final db = await dbHandler.initializeDB();
  final result = await db.rawQuery(
    "SELECT SUM(amount) as total FROM spending_transactions "
    "WHERE type='expense' AND date LIKE '$yearMonth%'"
  );
  final value = result.first['total'];
  return (value != null ? (value as num).toDouble() : 0.0);
}

/// 이번 달 예산 합계
Future<double> getMonthlyBudget(String yearMonth) async {
  final db = await dbHandler.initializeDB();
  final result = await db.rawQuery(
    "SELECT SUM(targetAmount) as total FROM monthly_budget WHERE yearMonth=?",
    [yearMonth],
  );
  final value = result.first['total'];
  return (value != null ? (value as num).toDouble() : 0.0);
}

/// 카테고리별 지출
Future<List<Map<String, dynamic>>> getCategoryExpense(String yearMonth) async {
  final db = await dbHandler.initializeDB();
  final result = await db.rawQuery("""
    SELECT c.id, c.c_name as name,
    IFNULL(SUM(CASE WHEN t.type='expense' THEN t.amount ELSE 0 END),0) as total_expense,
    IFNULL(SUM(CASE WHEN t.type='income' THEN t.amount ELSE 0 END),0) as total_income
    FROM categories c
    LEFT JOIN spending_transactions t ON c.id = t.c_id AND t.date LIKE '$yearMonth%'
    GROUP BY c.id
  """);

  // 안전하게 double 변환
  return result.map((r) {
    return {
      'id': r['id'],
      'name': r['name'],
      'total_expense': (r['total_expense'] as num?)?.toDouble() ?? 0.0,
      'total_income': (r['total_income'] as num?)?.toDouble() ?? 0.0,
    };
  }).toList();
}

/// Top3 카테고리
Future<List<Map<String, dynamic>>> getTop3Categories(String yearMonth) async {
  final db = await dbHandler.initializeDB();
  final result = await db.rawQuery("""
    SELECT c.id, c.c_name as name,
    SUM(CASE WHEN t.type='expense' THEN t.amount ELSE 0 END) as total
    FROM categories c
    LEFT JOIN spending_transactions t ON c.id = t.c_id AND t.date LIKE '$yearMonth%'
    GROUP BY c.id
    ORDER BY total DESC
    LIMIT 3
  """);

  return result.map((r) {
    return {
      'id': r['id'],
      'name': r['name'],
      'total': (r['total'] as num?)?.toDouble() ?? 0.0,
    };
  }).toList();
}

/// 특정 카테고리 breakdown
Future<Map<String, double>> getCategoryBreakdown(int categoryId) async {
  final db = await dbHandler.initializeDB();
  final result = await db.rawQuery("""
    SELECT t_name, SUM(amount) as total
    FROM spending_transactions
    WHERE c_id=? AND type='expense'
    GROUP BY t_name
    ORDER BY total DESC
    LIMIT 3
  """, [categoryId]);

  Map<String, double> map = {};
  for (var r in result) {
    map[r['t_name'] as String] = (r['total'] as num?)?.toDouble() ?? 0.0;
  }
  return map;
}

/// 최근 거래 가져오기
Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 5}) async {
  final db = await dbHandler.initializeDB();
  final result = await db.rawQuery("""
    SELECT t_id, c_id, t_name, date, type, amount, memo, isRecurring
    FROM spending_transactions
    ORDER BY date DESC
    LIMIT ?
  """, [limit]);

  // amount를 double로 안전하게 변환
  return result.map((r) {
    return {
      't_id': r['t_id'],
      'c_id': r['c_id'],
      't_name': r['t_name'],
      'date': r['date'],
      'type': r['type'],
      'amount': (r['amount'] as num?)?.toDouble() ?? 0.0,
      'memo': r['memo'],
      'isRecurring': r['isRecurring'] == 1,
    };
  }).toList();
}
}