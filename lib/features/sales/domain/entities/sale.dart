import 'sale_item.dart';

class Sale {
  Sale({
    required this.id,
    required this.saleDate,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.items,
    this.customerId,
    this.customerName,
    this.notes,
  });

  final int id;
  final int? customerId;
  final String? customerName;
  final DateTime saleDate;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String? notes;
  final List<SaleItem> items;
}
