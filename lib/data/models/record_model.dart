class RecordModel {
  final int? id; // [DB: INTEGER] Primary Key
  final int categoryId;
  final String name;
  final String date; // [DB: TEXT] ISO8601 String (YYYY-MM-DD)
  final String type; // [DB: TEXT] 'income' or 'expense'
  final double amount;
  final String memo;
  final bool isRecurring; // [DB: INTEGER] 1 for true, 0 for false

  RecordModel({
    this.id,
    required this.categoryId,
    required this.name,
    required this.date,
    required this.type,
    required this.amount,
    required this.memo,
    required this.isRecurring,
  });

  // Creates a copy of RecordModel with updated fields.
  RecordModel copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? date,
    String? type,
    double? amount,
    String? memo,
    bool? isRecurring,
  }) {
    return RecordModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }

  factory RecordModel.fromMap(Map<String, dynamic> map) {
    return RecordModel(
      id: map['id'],
      categoryId: map['category_id'],
      name: map['name'],
      date: map['date'],
      type: map['type'],
      amount: (map['amount'] as num).toDouble(),
      memo: map['memo'] ?? '',
      isRecurring: map['is_recurring'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'date': date,
      'type': type,
      'amount': amount,
      'memo': memo,
      'is_recurring': isRecurring ? 1 : 0,
    };
  }
}
