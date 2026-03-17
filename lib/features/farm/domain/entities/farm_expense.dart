class FarmExpense {
  FarmExpense({
    this.id,
    this.plantingId,
    this.plantingLabel,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.notes,
  });

  final int? id;
  final int? plantingId;
  final String? plantingLabel;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
  final String? notes;
}
