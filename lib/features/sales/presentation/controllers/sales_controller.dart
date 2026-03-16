import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/usecases/cancel_sale_usecase.dart';
import '../../domain/usecases/get_sales_usecase.dart';
import '../../domain/usecases/register_sale_usecase.dart';

class SalesController extends StateNotifier<AsyncValue<List<Sale>>> {
  SalesController(this._getSales, this._registerSale, this._cancelSale)
      : super(const AsyncValue.loading()) {
    load();
  }

  final GetSalesUseCase _getSales;
  final RegisterSaleUseCase _registerSale;
  final CancelSaleUseCase _cancelSale;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getSales.call);
  }

  Future<void> register({
    int? customerId,
    required DateTime saleDate,
    required String paymentMethod,
    String? notes,
    required List<SaleItem> items,
  }) async {
    await _registerSale(
      customerId: customerId,
      saleDate: saleDate,
      paymentMethod: paymentMethod,
      notes: notes,
      items: items,
    );
    await load();
  }

  Future<void> cancel(int saleId) async {
    await _cancelSale(saleId);
    await load();
  }
}
