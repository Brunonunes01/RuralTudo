import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/customer.dart';
import '../../domain/usecases/delete_customer_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/upsert_customer_usecase.dart';

class CustomerController extends StateNotifier<AsyncValue<List<Customer>>> {
  CustomerController(this._getCustomers, this._upsertCustomer, this._deleteCustomer)
      : super(const AsyncValue.loading()) {
    load();
  }

  final GetCustomersUseCase _getCustomers;
  final UpsertCustomerUseCase _upsertCustomer;
  final DeleteCustomerUseCase _deleteCustomer;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_getCustomers.call);
  }

  Future<void> save({
    int? id,
    required String name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    await _upsertCustomer(
      Customer(
        id: id,
        name: name,
        phone: phone,
        address: address,
        notes: notes,
        createdAt: DateTime.now(),
      ),
    );
    await load();
  }

  Future<void> remove(int id) async {
    await _deleteCustomer(id);
    await load();
  }
}
