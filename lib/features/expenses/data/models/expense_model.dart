import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  ExpenseModel({
    required super.id,
    required super.description,
    required super.category,
    required super.amount,
    required super.date,
    required super.createdAt,
    super.notes,
  });

  factory ExpenseModel.fromMap(Map<String, Object?> map) {
    return ExpenseModel(
      id: map['id'] as int,
      description: map['description'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'description': description,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
      };

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      description: expense.description,
      category: expense.category,
      amount: expense.amount,
      date: expense.date,
      notes: expense.notes,
      createdAt: expense.createdAt,
    );
  }
}
