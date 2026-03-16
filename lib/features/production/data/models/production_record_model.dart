import '../../domain/entities/production_record.dart';

class ProductionRecordModel extends ProductionRecord {
  ProductionRecordModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.productionType,
    required super.quantity,
    required super.date,
    required super.createdAt,
    super.estimatedCost,
    super.notes,
  });

  factory ProductionRecordModel.fromMap(Map<String, Object?> map) {
    return ProductionRecordModel(
      id: map['id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      productionType: map['production_type'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      estimatedCost: (map['estimated_cost'] as num?)?.toDouble(),
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
