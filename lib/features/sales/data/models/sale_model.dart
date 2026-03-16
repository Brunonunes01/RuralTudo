import '../../domain/entities/sale.dart';
import 'sale_item_model.dart';

class SaleModel extends Sale {
  SaleModel({
    required super.id,
    required super.saleDate,
    required super.totalAmount,
    required super.paymentMethod,
    required super.status,
    required super.items,
    super.customerId,
    super.customerName,
    super.notes,
  });

  factory SaleModel.fromMap(Map<String, Object?> map, List<SaleItemModel> items) {
    return SaleModel(
      id: map['id'] as int,
      customerId: map['customer_id'] as int?,
      customerName: map['customer_name'] as String?,
      saleDate: DateTime.parse(map['sale_date'] as String),
      totalAmount: (map['total_amount'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      status: map['status'] as String,
      notes: map['notes'] as String?,
      items: items,
    );
  }
}
