import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpsertCustomerUseCase {
  UpsertCustomerUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call(Customer customer) => _repository.upsert(customer);
}
