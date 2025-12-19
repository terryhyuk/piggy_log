import 'package:piggy_log/VM/database_handler.dart';

class CalenderHandler {
  final DatabaseHandler handler = DatabaseHandler();

  // total (expense - income)
  Future<Map<String, double>> getDailyTotals()async{
    final db = await handler.initializeDB();
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

  // 
Future<List<Map<String, dynamic>>> getTransactionsByDate(String date) async {
  final db = await handler.initializeDB();
  final result = await db.rawQuery(
    """
    SELECT t_id, t_name, amount, type, memo
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
  }).toList();
}

}