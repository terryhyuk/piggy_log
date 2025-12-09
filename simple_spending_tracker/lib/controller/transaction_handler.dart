import 'package:simple_spending_tracker/VM/database_handler.dart';
import 'package:simple_spending_tracker/model/spending_transaction.dart';

class TransactionHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

  // Insert Transaction
  Future<int> insertTransaction(SpendingTransaction res) async {
    final db = await databaseHandler.initializeDB();

    return await db.rawInsert(
      """
      insert into spending_transactions 
      (c_id, t_name, date, type, amount, memo, isRecurring)
      values (?, ?, ?, ?, ?, ?, ?)
      """,
      [
        res.c_id,
        res.t_name,
        DateTime.now().toLocal().toString(), // Convert to local time toString(),
        res.type,
        res.amount,
        res.memo,
        res.isRecurring ? 1 : 0,
      ],
    );
  }

  // Get Transactions By Category
  Future<List<SpendingTransaction>> getTransactionsByCategory(int categoryId) async {
    final db = await databaseHandler.initializeDB();

    final result = await db.rawQuery(
      """
      select * from spending_transactions
      where c_id = ?
      order by date desc
      """,
      [categoryId],
    );

    return result.map((e) => SpendingTransaction.fromMap(e)).toList();
  }

  // Update Transaction
  Future<int> updateTransaction(SpendingTransaction trx) async {
    final db = await databaseHandler.initializeDB();

    return await db.update(
      'spending_transactions',
      {
        't_name': trx.t_name,
        'c_id': trx.c_id,
        'date': trx.date,
        'type': trx.type,
        'amount': trx.amount,
        'memo': trx.memo,
        'isRecurring': trx.isRecurring ? 1 : 0,
      },
      where: 't_id = ?',
      whereArgs: [trx.t_id],
    );
  }

  // Get total spending for a category
Future<double> getCategoryTotal(int categoryId) async {
  final db = await databaseHandler.initializeDB();

  final List<Map<String, dynamic>> result = await db.rawQuery(
    """
    select SUM(amount) as total
    from spending_transactions
    where c_id = ?
    """,
    [categoryId],
  );

  // SQLite returns null if no rows exist
  final value = result.first['total'];
  return value == null ? 0.0 : (value as num).toDouble();
}

}
