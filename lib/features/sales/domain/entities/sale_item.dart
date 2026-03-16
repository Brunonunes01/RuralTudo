class SaleItem {
  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final int productId;
  final String productName;
  final double quantity;
  final double unitPrice;

  double get subtotal => quantity * unitPrice;
}
