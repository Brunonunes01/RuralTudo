class ProductionRecord {
  ProductionRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productionType,
    required this.quantity,
    required this.date,
    required this.createdAt,
    this.estimatedCost,
    this.notes,
  });

  final int? id;
  final int productId;
  final String productName;
  final String productionType;
  final double quantity;
  final double? estimatedCost;
  final DateTime date;
  final String? notes;
  final DateTime createdAt;
}
