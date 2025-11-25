class Monthlybudget {
  // Property
  final int? m_id;
  final int? c_id;
  final String yearMonth; // yyyy-MM
  final double targetAmount;

  Monthlybudget({
    this.m_id,
    required this.c_id,
    required this.yearMonth,
    required this.targetAmount
  });

  Monthlybudget.fromMap(Map<String, dynamic> res)
  : m_id = res['m_id'],
  c_id = res['c_id'],
  yearMonth = res['yearMonth'],
  targetAmount = (res['targetAmount']as num).toDouble();
}