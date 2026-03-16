class Product {
  Product({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.productType,
    required this.unit,
    required this.costPrice,
    required this.salePrice,
    required this.stockQuantity,
    required this.minStock,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  final int? id;
  final String name;
  final String? description;
  final int categoryId;
  final String productType;
  final String unit;
  final double costPrice;
  final double salePrice;
  final double stockQuantity;
  final double minStock;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stockQuantity <= minStock;
}
