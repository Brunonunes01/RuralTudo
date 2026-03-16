import '../../domain/entities/stock_movement.dart';

class StockMovementModel extends StockMovement {
  StockMovementModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.movementType,
    required super.origin,
    required super.quantity,
    required super.date,
    super.notes,
  });

  factory StockMovementModel.fromMap(Map<String, Object?> map) {
    return StockMovementModel(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      movementType: map['movement_type'] as String,
      origin: map['origin'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }
}
