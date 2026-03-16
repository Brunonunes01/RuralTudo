import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.name,
    required super.categoryId,
    required super.productType,
    required super.unit,
    required super.costPrice,
    required super.salePrice,
    required super.stockQuantity,
    required super.minStock,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.description,
  });

  factory ProductModel.fromMap(Map<String, Object?> map) {
    return ProductModel(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      categoryId: map['category_id'] as int,
      productType: map['product_type'] as String,
      unit: map['unit'] as String,
      costPrice: (map['cost_price'] as num).toDouble(),
      salePrice: (map['sale_price'] as num).toDouble(),
      stockQuantity: (map['stock_quantity'] as num).toDouble(),
      minStock: (map['min_stock'] as num).toDouble(),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'product_type': productType,
      'unit': unit,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'stock_quantity': stockQuantity,
      'min_stock': minStock,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      categoryId: entity.categoryId,
      productType: entity.productType,
      unit: entity.unit,
      costPrice: entity.costPrice,
      salePrice: entity.salePrice,
      stockQuantity: entity.stockQuantity,
      minStock: entity.minStock,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
