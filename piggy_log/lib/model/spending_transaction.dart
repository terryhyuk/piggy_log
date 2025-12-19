

class SpendingTransaction {
  // Property
  final int? t_id;
  final int? c_id;
  final String t_name;   // A short title/label describing the transaction
  final String date;
  final String type; // 'income' or 'expense'
  final double amount;
  final String memo;   //Optional additional notes / memo about the transaction
  final bool isRecurring;   /// Whether this transaction repeats (ex: rent, subscriptions, transit pass)

  SpendingTransaction({
    this.t_id,
    required this.c_id,
    required this.t_name,
    required this.date,
    required this.type,
    required this.amount,
    required this.memo,
    required this.isRecurring,
  });

  SpendingTransaction.fromMap(Map<String, dynamic> res)
  : t_id = res['t_id'],
  c_id = res['c_id'],
  t_name = res['t_name'],
  date = res['date'],
  type = res['type'],
  amount = (res['amount']as num).toDouble(),
  memo = res['memo'],
  isRecurring = res['isRecurring'] == 1;

}