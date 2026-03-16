import '../../domain/entities/sale_item.dart';

class SaleItemModel extends SaleItem {
  SaleItemModel({
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
  });

  factory SaleItemModel.fromMap(Map<String, Object?> map) {
    return SaleItemModel(
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unit_price'] as num).toDouble(),
    );
  }
}
