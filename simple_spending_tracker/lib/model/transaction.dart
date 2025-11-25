

class Transaction {
  // Property
  final int? t_id;
  final int? c_id;
  final String date;
  final String type; // 'income' or 'expense'
  final double amount;
  final String memo;
  final bool isRecurring;

  Transaction({
    this.t_id,
    required this.c_id,
    required this.date,
    required this.type,
    required this.amount,
    required this.memo,
    required this.isRecurring,
  });

  Transaction.fromMap(Map<String, dynamic> res)
  : t_id = res['t_id'],
  c_id = res['c_id'],
  date = res['date'],
  type = res['type'],
  amount = (res['amount']as num).toDouble(),
  memo = res['memo'],
  isRecurring = res['isRecurring'] == 1;

}