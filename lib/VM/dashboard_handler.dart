import 'package:sqflite/sqlite_api.dart';

import 'database_handler.dart';

class DashboardHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  Future<Database> _getDb() async {
    return await databaseHandler.database;
  }

/// Fetches category-wise spending within a specific date range.
  /// Explains: Uses BETWEEN for flexible date filtering (Dashboard & Analysis).
  Future<List<Map<String, dynamic>>> getCategoryExpenseByRange(String start, String end) async {
    final db = await _getDb();
    final result = await db.rawQuery("""
      SELECT c.id, c.c_name as name,
      IFNULL(SUM(CASE WHEN t.type='expense' THEN t.amount ELSE 0 END), 0) as total_expense,
      IFNULL(SUM(CASE WHEN t.type='income' THEN t.amount ELSE 0 END), 0) as total_income
      FROM categories c
      LEFT JOIN spending_transactions t ON c.id = t.c_id 
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
  
/// 기간별 또는 월별 총 지출액 (통합 버전)
Future<double> getMonthlyTotalExpense({String? yearMonth, String? startDate, String? endDate}) async {
  // final db = await databaseHandler.initializeDB();
  final db = await _getDb();
  
  String query;
  List<dynamic> args;

  if (startDate != null && endDate != null) {
    // 1. 달력 범위 선택 시 (BETWEEN 사용)
    query = "SELECT SUM(amount) as total FROM spending_transactions WHERE type='expense' AND date BETWEEN ? AND ?";
    args = [startDate, endDate];
  } else {
    // 2. 기본 월별 조회 시 (LIKE 사용)
    query = "SELECT SUM(amount) as total FROM spending_transactions WHERE type='expense' AND date LIKE ?";
    args = ['$yearMonth%'];
  }

  final result = await db.rawQuery(query, args);
  final value = result.first['total'];
  return (value != null ? (value as num).toDouble() : 0.0);
}

/// 카테고리별 지출
Future<List<Map<String, dynamic>>> getCategoryExpense(String yearMonth) async {
  // final db = await databaseHandler.initializeDB();
  final db = await _getDb();
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

// /// Top3 카테고리
// Future<List<Map<String, dynamic>>> getTop3Categories(String yearMonth) async {
//   // final db = await databaseHandler.initializeDB();
//   final db = await _getDb();
//   final result = await db.rawQuery("""
//     SELECT c.id, c.c_name as name,
//     SUM(CASE WHEN t.type='expense' THEN t.amount ELSE 0 END) as total
//     FROM categories c
//     LEFT JOIN spending_transactions t ON c.id = t.c_id AND t.date LIKE '$yearMonth%'
//     GROUP BY c.id
//     ORDER BY total DESC
//     LIMIT 3
//   """);

//   return result.map((r) {
//     return {
//       'id': r['id'],
//       'name': r['name'],
//       'total': (r['total'] as num?)?.toDouble() ?? 0.0,
//     };
//   }).toList();
// }

/// 특정 카테고리 breakdown
Future<Map<String, double>> getCategoryBreakdown(int categoryId) async {
  // final db = await databaseHandler.initializeDB();
  final db = await _getDb();
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

/// 최근 거래 가져오기 (오빠의 DB 구조에 최적화)
Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 5}) async {
  final db = await _getDb();
  
  final result = await db.rawQuery("""
    SELECT t.*, c.icon_codepoint, c.icon_font_family, c.icon_font_package, c.color
    FROM spending_transactions t
    LEFT JOIN categories c ON t.c_id = c.id
    ORDER BY t.date DESC LIMIT ?
  """, [limit]);

  // 💡 [STEP 1] DB에서 막 나온 따끈따끈한 로우 데이터를 확인합니다.
  // Checking if the raw SQL result contains the expected category data.
  for (var row in result) {
    print("--- DB RAW ROW ---");
    print("Name: ${row['t_name']}, Code: ${row['icon_codepoint']}, Pkg: ${row['icon_font_package']}");
  }

  final mappedList = result.map((row) {
    final Map<String, dynamic> mapped = {
      ...row,
      'icon_codepoint': row['icon_codepoint'],
      'icon_font_family': row['icon_font_family'],
      'icon_font_package': row['icon_font_package'],
      'color': row['color'],
    };
    
    // 💡 [STEP 2] 위젯으로 보내기 위해 새롭게 포장된 Map 데이터를 확인합니다.
    // Verifying if the re-mapped Map has preserved the category information.
    print("--- MAPPED MAP ---");
    print("Code: ${mapped['icon_codepoint']}, Pkg: ${mapped['icon_font_package']}");
    
    return mapped;
  }).toList();

  return mappedList;
}

// Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 5}) async {
//   final db = await _getDb();
//   final result = await db.rawQuery("""
//     SELECT t.*, c.icon_codepoint, c.icon_font_family, c.color
//     FROM spending_transactions t
//     LEFT JOIN categories c ON t.c_id = c.id
//     ORDER BY t.date DESC LIMIT ?
//   """, [limit]);

//   // 💡 [DEBUG LOG] 이 로그가 디버그 콘솔에 뭐라고 찍히는지 확인해줘!
//   for (var row in result) {
//     print("DEBUG: Transaction: ${row['t_name']}, Category ID: ${row['c_id']}, Icon: ${row['icon_codepoint']}, Color: ${row['color']}");
//   }

//   return result.toList();
// }
// Future<List<Map<String, dynamic>>> getRecentTransactions({int limit = 5}) async {
//   // final db = await databaseHandler.initializeDB();
//   final db = await _getDb();
//   final result = await db.rawQuery("""
//     SELECT t_id, c_id, t_name, date, type, amount, memo, isRecurring
//     FROM spending_transactions
//     ORDER BY date DESC
//     LIMIT ?
//   """, [limit]);

//   // amount를 double로 안전하게 변환
//   return result.map((r) {
//     return {
//       't_id': r['t_id'],
//       'c_id': r['c_id'],
//       't_name': r['t_name'],
//       'date': r['date'],
//       'type': r['type'],
//       'amount': (r['amount'] as num?)?.toDouble() ?? 0.0,
//       'memo': r['memo'],
//       'isRecurring': r['isRecurring'] == 1,
//     };
//   }).toList();
// }

// 1. Get unique templates marked as Recurring
Future<List<Map<String, dynamic>>> getRecurringTemplates() async {
  // final db = await databaseHandler.initializeDB();
  final db = await _getDb();
  // Grouping by name and amount to get templates for each recurring item
  // Table name updated to 'spending_transactions'
  return await db.rawQuery('''
    SELECT * FROM spending_transactions 
    WHERE isRecurring = 1 
    GROUP BY t_name, amount 
  ''');
}

// 2. Check if the same item already exists in the given month
Future<bool> checkIfAlreadyAdded(String title, double amount, String yearMonth) async {
  // final db = await databaseHandler.initializeDB();
  final db = await _getDb();
  // Table name updated to 'spending_transactions'
  final result = await db.query(
    'spending_transactions',
    where: 't_name = ? AND amount = ? AND date LIKE ?',
    whereArgs: [title, amount, '$yearMonth%'],
  );
  return result.isNotEmpty;
}

// 3. New transaction insertion (Helper for auto-recurring)
Future<void> insertTransaction(Map<String, dynamic> data) async {
  // final db = await databaseHandler.initializeDB();
  final db = await _getDb();
  await db.insert('spending_transactions', data);
}

Future<List<Map<String, dynamic>>> getCategoryDetailedList(int categoryId) async {
  final db = await _getDb();
  return await db.query(
    'spending_transactions', 
    where: 'c_id = ? AND type = "expense"', 
    whereArgs: [categoryId],
    orderBy: 'date ASC'
  );
}

}