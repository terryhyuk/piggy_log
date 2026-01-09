//  BudgetModel: Monthly budget targets.
class BudgetModel {
  final int? id;              
  final int categoryId;       
  final String yearMonth;     
  final double targetAmount;  // [DB: REAL] Goal amount

  BudgetModel({
    this.id,
    required this.categoryId,
    required this.yearMonth,
    required this.targetAmount,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      categoryId: map['category_id'],
      yearMonth: map['year_month'],
      targetAmount: (map['target_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'year_month': yearMonth,
      'target_amount': targetAmount,
    };
  }
}