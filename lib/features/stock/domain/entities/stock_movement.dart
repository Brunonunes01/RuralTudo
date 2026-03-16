class StockMovement {
  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.movementType,
    required this.origin,
    required this.quantity,
    required this.date,
    this.notes,
  });

  final int id;
  final int productId;
  final String productName;
  final String movementType;
  final String origin;
  final double quantity;
  final DateTime date;
  final String? notes;
}
