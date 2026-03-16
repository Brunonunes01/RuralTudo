import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  GetCustomersUseCase(this._repository);

  final CustomerRepository _repository;

  Future<List<Customer>> call() => _repository.getAll();
}
