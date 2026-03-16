import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/upsert_product_usecase.dart';

class ProductController extends StateNotifier<AsyncValue<List<Product>>> {
  ProductController(
    this._getProducts,
    this._upsertProduct,
    this._deleteProduct,
  ) : super(const AsyncValue.loading()) {
    load();
  }

  final GetProductsUseCase _getProducts;
  final UpsertProductUseCase _upsertProduct;
  final DeleteProductUseCase _deleteProduct;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getProducts.call);
  }

  Future<void> save({
    int? id,
    required String name,
    String? description,
    required int categoryId,
    required String productType,
    required String unit,
    required double costPrice,
    required double salePrice,
    required double stockQuantity,
    required double minStock,
    required bool isActive,
  }) async {
    final now = DateTime.now();
    await _upsertProduct(
      Product(
        id: id,
        name: name,
        description: (description == null || description.isEmpty) ? null : description,
        categoryId: categoryId,
        productType: productType,
        unit: unit,
        costPrice: costPrice,
        salePrice: salePrice,
        stockQuantity: stockQuantity,
        minStock: minStock,
        isActive: isActive,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await load();
  }

  Future<void> remove(int id) async {
    await _deleteProduct(id);
    await load();
  }
}
