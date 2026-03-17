class HarvestSale {
  HarvestSale({
    this.id,
    required this.harvestId,
    required this.cropName,
    this.customerName,
    required this.saleDate,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalAmount,
    required this.paymentMethod,
    this.notes,
  });

  final int? id;
  final int harvestId;
  final String cropName;
  final String? customerName;
  final DateTime saleDate;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalAmount;
  final String paymentMethod;
  final String? notes;
}
