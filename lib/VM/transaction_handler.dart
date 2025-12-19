import 'package:piggy_log/VM/database_handler.dart';
import 'package:piggy_log/model/spending_transaction.dart';

class TransactionHandler {
  final DatabaseHandler databaseHandler = DatabaseHandler();

Future<int> insertTransaction(
    SpendingTransaction res, {
    DateTime? customDate, // 선택적 날짜
  }) async {
  final db = await databaseHandler.initializeDB();

  // 1️⃣ 지정 날짜가 있으면 사용, 없으면 오늘
  DateTime date = customDate ?? DateTime.now();

  // 2️⃣ 미래 날짜 막기 (오늘 이후면 오늘로 강제)
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day); // 오늘 00:00
  final dateOnly = DateTime(date.year, date.month, date.day); // 날짜만 비교

  if (dateOnly.isAfter(todayOnly)) {
    date = todayOnly;
  } else {
    date = dateOnly;
  }

  // 3️⃣ DB에 YYYY-MM-DD 형식으로 저장
  final dateStr =
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  print("=== INSERT DATE === $dateStr"); // 확인용

  // 4️⃣ DB insert
  return await db.rawInsert(
    """
    INSERT INTO spending_transactions
    (c_id, t_name, date, type, amount, memo, isRecurring)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    """,
    [
      res.c_id,
      res.t_name,
      dateStr,
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

  // delete Transaction
  Future<void> deleteTransaction(int transactionId) async {
    final db = await databaseHandler.initializeDB();
    await db.delete(
      'spending_transactions',
      where: 't_id = ?',
      whereArgs: [transactionId],
    );
  }
}
