class Expense {
  Expense({
    required this.id,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.notes,
  });

  final int? id;
  final String description;
  final String category;
  final double amount;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
}
