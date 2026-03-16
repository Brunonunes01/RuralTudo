import '../repositories/customer_repository.dart';

class DeleteCustomerUseCase {
  DeleteCustomerUseCase(this._repository);

  final CustomerRepository _repository;

  Future<void> call(int id) => _repository.delete(id);
}
