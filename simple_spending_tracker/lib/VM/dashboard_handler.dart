import 'package:simple_spending_tracker/model/spending_transaction.dart';
import 'package:simple_spending_tracker/VM/database_handler.dart';

class DashboardHandler {
  // Property
  final DatabaseHandler databaseHandler = DatabaseHandler();

  // --------------------------
  // Get total expense for a given month (yyyy-MM)
  // --------------------------
  Future<double> getMonthlyTotalExpense(String yearMonth) async {
    final db = await databaseHandler.initializeDB();
    final res = await db.rawQuery(
      'select sum(amount) as total from spending_transactions where type = ? and date like ?',
      ['expense', '$yearMonth%'],
    );
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // --------------------------
  // Get total budget for a given month
  // --------------------------
  Future<double> getMonthlyBudget(String yearMonth) async {
    final db = await databaseHandler.initializeDB();
    final res = await db.rawQuery(
      'select sum(targetAmount) as total from monthly_budget where yearMonth = ?',
      [yearMonth],
    );
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // --------------------------
  // Get category-wise expense summary
  // returns list of {id, name, total}
  // --------------------------
  Future<List<Map<String, dynamic>>> getCategoryExpense(String yearMonth) async {
    final db = await databaseHandler.initializeDB();
    final res = await db.rawQuery(
      'select c.id as id, c_name as name, sum(t.amount) as total '
      'from spending_transactions t '
      'join categories c on t.c_id = c.id '
      'where t.type = ? and t.date like ? '
      'group by c.id, c_name',
      ['expense', '$yearMonth%'],
    );
    return res.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  // --------------------------
  // Get top 3 spending categories
  // --------------------------
  Future<List<Map<String, dynamic>>> getTop3Categories(String yearMonth) async {
    final db = await databaseHandler.initializeDB();
    final res = await db.rawQuery(
      'select c.id as id, c_name as name, sum(t.amount) as total '
      'from spending_transactions t '
      'join categories c on t.c_id = c.id '
      'where t.type = ? and t.date like ? '
      'group by c.id, c_name '
      'order by total desc limit 3',
      ['expense', '$yearMonth%'],
    );
    return res.map((r) {
      return {
        'id': r['id'],
        'name': r['name'],
        'total': (r['total'] as num?)?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  // --------------------------
  // Get recent transactions (default 4)
  // --------------------------
  Future<List<SpendingTransaction>> getRecentTransactions({int limit = 4}) async {
    final db = await databaseHandler.initializeDB();
    final res = await db.rawQuery(
      'select * from spending_transactions order by date desc limit ?',
      [limit],
    );
    return res.map((r) => SpendingTransaction.fromMap(r)).toList();
  }

  // --------------------------
// Get breakdown for a specific category
// return: { 'Coffee': 12.5, 'Meal': 30.0, 'Snack': 8.0 }
// --------------------------
Future<Map<String, double>> getCategoryBreakdown(int categoryId) async {
  final db = await databaseHandler.initializeDB();
  final res = await db.rawQuery(
    'select t_name, sum(amount) as total '
    'from spending_transactions '
    'where c_id = ? and type = ? '
    'group by t_name',
    [categoryId, 'expense'],
  );

  final Map<String, double> map = {};
  for (var r in res) {
    final key = (r['t_name'] as String?) ?? 'Unknown';
    map[key] = (r['total'] as num?)?.toDouble() ?? 0.0;
  }
  return map;
}


}// ENd 
